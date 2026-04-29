param(
  [Parameter(Mandatory = $true)]
  [string]$Source,
  [ValidateSet('overview', 'detail')]
  [string]$Mode = 'overview',
  [string]$Method,
  [string]$Path,
  [string]$Tag,
  [string]$Keyword
)

$ErrorActionPreference = 'Stop'

function Is-Object($value) {
  return $null -ne $value -and $value -is [psobject]
}

function Get-Property($object, $name) {
  if (-not (Is-Object $object)) { return $null }
  $prop = $object.PSObject.Properties[$name]
  if ($prop) { return $prop.Value }
  return $null
}

function Get-SchemaType($schema) {
  if (-not (Is-Object $schema)) { return $null }
  $type = Get-Property $schema 'type'
  if ($type) { return [string]$type }
  $ref = Get-Property $schema '$ref'
  if ($ref) { return ([string]$ref).Split('/')[-1] }
  return $null
}

function Get-SchemaFields($schema) {
  $fields = @()
  if (-not (Is-Object $schema)) { return $fields }
  $properties = Get-Property $schema 'properties'
  if (-not $properties) { return $fields }
  $required = @()
  $requiredValue = Get-Property $schema 'required'
  if ($requiredValue) { $required = @($requiredValue) }
  foreach ($prop in $properties.PSObject.Properties) {
    $fieldSchema = $prop.Value
    $fields += [pscustomobject]@{
      name = $prop.Name
      type = Get-SchemaType $fieldSchema
      required = ($required -contains $prop.Name)
      description = [string](Get-Property $fieldSchema 'description')
    }
  }
  return $fields
}

function Format-Fields($fields) {
  if (@($fields).Count -eq 0) { return @('- 未声明字段。') }
  return @($fields | ForEach-Object {
    $required = if ($_.required) { '（必填）' } else { '' }
    $description = if ($_.description) { " - $($_.description)" } else { '' }
    "- $($_.name)$required`: $($_.type)$description"
  })
}

function Format-Parameters($parameters, $location) {
  $items = @($parameters | Where-Object { $_.in -eq $location })
  if ($items.Count -eq 0) { return @('- 未声明。') }
  return @($items | ForEach-Object {
    $required = if ($_.required) { '（必填）' } else { '' }
    $description = if ($_.description) { " - $($_.description)" } else { '' }
    "- $($_.name)$required`: $($_.type)$description"
  })
}

function Read-Security($value) {
  $items = @()
  if ($value) {
    foreach ($securityItem in @($value)) {
      foreach ($prop in $securityItem.PSObject.Properties) {
        $items += $prop.Name
      }
    }
  }
  return $items
}

function Parse-Parameters($value) {
  $parameters = @()
  foreach ($parameter in @($value)) {
    if (-not $parameter) { continue }
    $schema = Get-Property $parameter 'schema'
    $parameters += [pscustomobject]@{
      name = [string](Get-Property $parameter 'name')
      in = [string](Get-Property $parameter 'in')
      required = ((Get-Property $parameter 'required') -eq $true)
      type = if (Get-Property $parameter 'type') { [string](Get-Property $parameter 'type') } else { Get-SchemaType $schema }
      description = [string](Get-Property $parameter 'description')
    }
  }
  return $parameters
}

function Parse-RequestBody($operation, $parameters) {
  $requestBody = Get-Property $operation 'requestBody'
  if ($requestBody) {
    $content = Get-Property $requestBody 'content'
    if ($content) {
      $media = $content.PSObject.Properties | Select-Object -First 1
      if ($media) {
        return Get-SchemaFields (Get-Property $media.Value 'schema')
      }
    }
  }
  $bodyParam = @($parameters | Where-Object { $_.in -eq 'body' } | Select-Object -First 1)
  if ($bodyParam) {
    $rawParameters = Get-Property $operation 'parameters'
    foreach ($raw in @($rawParameters)) {
      if ((Get-Property $raw 'in') -eq 'body') {
        return Get-SchemaFields (Get-Property $raw 'schema')
      }
    }
  }
  return @()
}

function Parse-Responses($responses) {
  $items = @()
  if (-not $responses) { return $items }
  foreach ($prop in $responses.PSObject.Properties) {
    $response = $prop.Value
    $schema = Get-Property $response 'schema'
    $content = Get-Property $response 'content'
    if ($content) {
      $media = $content.PSObject.Properties | Select-Object -First 1
      if ($media) { $schema = Get-Property $media.Value 'schema' }
    }
    $items += [pscustomobject]@{
      status = $prop.Name
      description = [string](Get-Property $response 'description')
      fields = @(Get-SchemaFields $schema)
    }
  }
  return $items
}

function Parse-Operations($doc) {
  $operations = @()
  $paths = Get-Property $doc 'paths'
  $globalSecurity = Read-Security (Get-Property $doc 'security')
  $isOpenApi = $null -ne (Get-Property $doc 'openapi')
  $servers = @()
  if ($isOpenApi) {
    foreach ($server in @((Get-Property $doc 'servers'))) { if (Get-Property $server 'url') { $servers += [string](Get-Property $server 'url') } }
  } else {
    $apiHost = [string](Get-Property $doc 'host')
    $basePath = [string](Get-Property $doc 'basePath')
    $schemes = @((Get-Property $doc 'schemes'))
    if ($schemes.Count -eq 0) { $schemes = @('https') }
    if ($apiHost) { $servers = @($schemes | ForEach-Object { "${_}://$apiHost$basePath" }) }
  }

  foreach ($pathProp in $paths.PSObject.Properties) {
    $pathItem = $pathProp.Value
    foreach ($methodProp in $pathItem.PSObject.Properties) {
      $method = $methodProp.Name.ToLowerInvariant()
      if (@('get', 'put', 'post', 'delete', 'patch', 'options', 'head', 'trace') -notcontains $method) { continue }
      $operation = $methodProp.Value
      $parameters = @(Parse-Parameters (Get-Property $operation 'parameters'))
      $security = Read-Security (Get-Property $operation 'security')
      if ($security.Count -eq 0) { $security = $globalSecurity }
      $operations += [pscustomobject]@{
        method = $method.ToUpperInvariant()
        path = $pathProp.Name
        tags = @((Get-Property $operation 'tags'))
        operationId = [string](Get-Property $operation 'operationId')
        summary = [string](Get-Property $operation 'summary')
        description = [string](Get-Property $operation 'description')
        parameters = $parameters
        requestFields = @(Parse-RequestBody $operation $parameters)
        responses = @(Parse-Responses (Get-Property $operation 'responses'))
        security = $security
        servers = $servers
      }
    }
  }
  return $operations
}

function Format-Overview($doc, $operations) {
  $title = [string](Get-Property (Get-Property $doc 'info') 'title')
  $tagCounts = @{}
  foreach ($operation in $operations) {
    foreach ($tagItem in @($operation.tags)) {
      if (-not $tagCounts.ContainsKey($tagItem)) { $tagCounts[$tagItem] = 0 }
      $tagCounts[$tagItem]++
    }
  }
  $tagText = if ($tagCounts.Count -eq 0) { '未声明' } else { (($tagCounts.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name)($($_.Value))" }) -join '、') }
  $lines = @('# Swagger 概览', '', "文档：$title", "接口数量：$(@($operations).Count)", "标签统计：$tagText", '', '## 接口列表')
  foreach ($operation in $operations | Select-Object -First 30) {
    $summary = if ($operation.summary) { " - $($operation.summary)" } else { '' }
    $operationId = if ($operation.operationId) { " ($($operation.operationId))" } else { '' }
    $lines += "- $($operation.method) $($operation.path)$summary$operationId"
  }
  $lines += ''
  $lines += '下一步示例：`method:GET path:/pets mode:detail`'
  return ($lines -join "`n")
}

function Format-Detail($doc, $operation) {
  $title = [string](Get-Property (Get-Property $doc 'info') 'title')
  $lines = @(
    "# 接口详情：$($operation.method) $($operation.path)",
    '',
    "文档：$title",
    "说明：$(if ($operation.summary) { $operation.summary } elseif ($operation.description) { $operation.description } else { '未提供说明' })",
    "Base URL：$(if ($operation.servers.Count -gt 0) { $operation.servers[0] } else { '未声明' })",
    "认证：$(if ($operation.security.Count -gt 0) { $operation.security -join '、' } else { '未声明' })",
    '',
    '## 路径参数'
  )
  $lines += Format-Parameters $operation.parameters 'path'
  $lines += @('', '## 查询参数')
  $lines += Format-Parameters $operation.parameters 'query'
  $lines += @('', '## 请求头')
  $lines += Format-Parameters $operation.parameters 'header'
  $lines += @('', '## 请求体字段')
  if (@($operation.requestFields).Count -gt 0) { $lines += Format-Fields $operation.requestFields } else { $lines += '- 未声明请求体。' }
  $lines += @('', '## 响应')
  foreach ($response in $operation.responses) {
    $lines += "- $($response.status): $(if ($response.description) { $response.description } else { '未提供说明' })"
    $lines += @(Format-Fields $response.fields | ForEach-Object { "  $_" })
  }
  return ($lines -join "`n")
}

$doc = Get-Content -Raw -Encoding UTF8 -LiteralPath $Source | ConvertFrom-Json
$operations = @(Parse-Operations $doc)
if ($Method) { $operations = @($operations | Where-Object { $_.method -eq $Method.ToUpperInvariant() }) }
if ($Path) { $operations = @($operations | Where-Object { $_.path -eq $Path }) }
if ($Tag) { $operations = @($operations | Where-Object { @($_.tags) -contains $Tag }) }
if ($Keyword) {
  $operations = @($operations | Where-Object { "$($_.method) $($_.path) $($_.summary) $($_.operationId)" -like "*$Keyword*" })
}

if ($Mode -eq 'detail') {
  if ($operations.Count -eq 0) { throw 'No operation matched detail filters.' }
  Format-Detail $doc $operations[0]
} else {
  Format-Overview $doc $operations
}


