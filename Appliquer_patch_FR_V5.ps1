param([string]$SourceExe='')
$ErrorActionPreference = 'Stop'
$stage = $null
$outDir = $null
$success = $false

function SHA256-File([string]$Path) {
  return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}
function SHA256-Bytes([byte[]]$Bytes) {
  $algo = [System.Security.Cryptography.SHA256]::Create()
  try { return ([BitConverter]::ToString($algo.ComputeHash($Bytes))).Replace('-','').ToLowerInvariant() }
  finally { $algo.Dispose() }
}
function Apply-Operations([byte[]]$Bytes, $Ops, [string]$StageName) {
  foreach ($op in $Ops) {
    $offset = [int]$op.offset
    $old = [Convert]::FromBase64String([string]$op.old)
    $new = [Convert]::FromBase64String([string]$op.new)
    if ($offset -lt 0 -or $offset+$old.Length -gt $Bytes.Length -or $old.Length -ne $new.Length) {
      throw "Opération invalide ($StageName, position $offset)."
    }
    for ($i=0; $i -lt $old.Length; $i++) {
      if ($Bytes[$offset+$i] -ne $old[$i]) {
        throw "Fichier incompatible avec $StageName (position $offset)."
      }
    }
    [Array]::Copy($new,0,$Bytes,$offset,$new.Length)
  }
}
function Copy-GameResources([string]$From, [string]$To) {
  $needed = @('D3DX9_43.dll', 'options.ini')
  $needed += @('music_beako.ogg','music_ed_part1.ogg','music_ed_part2.ogg','music_emilia.ogg','music_puck.ogg','music_ram.ogg','music_sad.ogg','music_stinger.ogg','music_tension.ogg')
  foreach ($filename in $needed) {
    $candidate = Join-Path $From $filename
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
      Copy-Item -LiteralPath $candidate -Destination $To -ErrorAction Stop
    } else {
      Write-Host "Attention : ressource absente : $filename" -ForegroundColor Yellow
    }
  }
}

try {
  $patchDir=Split-Path -Parent $MyInvocation.MyCommand.Path
  $manifest=Get-Content -LiteralPath (Join-Path $patchDir 'patch_v5.json') -Raw -Encoding UTF8 | ConvertFrom-Json
  if ([string]::IsNullOrWhiteSpace($SourceExe)) {
    $SourceExe = Read-Host "Chemin de l'EXE anglais original (installeur ou EXE du jeu)"
  }
  $SourceExe = $SourceExe.Trim('"')
  if (-not (Test-Path -LiteralPath $SourceExe -PathType Leaf)) { throw 'EXE source introuvable.' }
  $SourceExe = (Resolve-Path -LiteralPath $SourceExe -ErrorAction Stop).ProviderPath
  $sourceHash = SHA256-File $SourceExe
  $sourceFolder = Split-Path -Parent $SourceExe
  $isSfx = $sourceHash -eq [string]$manifest.supported_original_package_sha256
  if (-not $isSfx -and $sourceHash -ne [string]$manifest.supported_original_inner_sha256) {
    throw "EXE non reconnu. Utilisez l'EXE anglais original, non une version FR. SHA256 : $sourceHash"
  }
  Write-Host 'Fichier original vérifié.' -ForegroundColor Green

  $innerPath = $SourceExe
  $resources = $sourceFolder
  if ($isSfx) {
    $stage=Join-Path ([IO.Path]::GetTempPath()) ('rezero_fr_v5_'+[Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $stage | Out-Null
    $archive=[System.IO.File]::ReadAllBytes($SourceExe)
    $start=[int]$manifest.cab_start
    if ($start -lt 0 -or ($start+12) -gt $archive.Length) { throw 'Archive CAB introuvable.' }
    if ($archive[$start] -ne 77 -or $archive[$start+1] -ne 83 -or $archive[$start+2] -ne 67 -or $archive[$start+3] -ne 70) {
      throw 'La signature CAB ne correspond pas.'
    }
    $cabSize=[int][BitConverter]::ToUInt32($archive,$start+8)
    if ($cabSize -lt 20000000 -or ($start+$cabSize) -gt $archive.Length) {throw 'Archive CAB incorrecte.'}
    $cabData = New-Object byte[] $cabSize
    [Array]::Copy($archive,$start,$cabData,0,$cabSize)
    $cabFile=Join-Path $stage 'game.cab'
    [IO.File]::WriteAllBytes($cabFile,$cabData)
    $extractDir=Join-Path $stage 'extracted'
    New-Item -ItemType Directory -Path $extractDir | Out-Null
    $expander=Join-Path $env:SystemRoot 'System32\expand.exe'
    if (-not (Test-Path -LiteralPath $expander)) {$expander='expand.exe'}
    & $expander '-F:*' $cabFile $extractDir | Out-Host
    if ($LASTEXITCODE -ne 0) {throw "Impossible d'extraire l'archive CAB du jeu anglais."}
    $innerPath=Join-Path $extractDir 'Re_Zero_After_Memories.exe'
    $resources=$extractDir
  }
  if (-not (Test-Path -LiteralPath $innerPath -PathType Leaf)) {throw "EXE du jeu anglais introuvable après extraction."}
  if ((SHA256-File $innerPath) -ne [string]$manifest.supported_original_inner_sha256) {throw 'L EXE extrait ne correspond pas au jeu attendu.'}
  $bytes=[IO.File]::ReadAllBytes($innerPath)
  if ($bytes.Length -ne [int]$manifest.original_inner_size) {throw 'Longueur inattendue du jeu anglais.'}
  foreach ($step in $manifest.stages) {
    Apply-Operations $bytes $step.ops ([string]$step.name)
    if ([string]$step.name -eq 'english_to_v3') {
      foreach ($kind in @('font','controls')) {
        if ($kind -eq 'font') {
          $assetName=[string]$manifest.font_atlas_file
          $offset=[int]$manifest.font_png_offset
          $span=[int]$manifest.font_png_span
          $expectedHash=[string]$manifest.font_png_sha256
        } else {
          $assetName=[string]$manifest.controls_file
          $offset=[int]$manifest.controls_png_offset
          $span=[int]$manifest.controls_png_span
          $expectedHash=[string]$manifest.controls_png_sha256
        }
        $assetPath=Join-Path $patchDir $assetName
        $assetBytes=[IO.File]::ReadAllBytes($assetPath)
        if ((SHA256-Bytes $assetBytes) -ne $expectedHash) {throw "Le fichier $assetName est corrompu."}
        if ($assetBytes.Length -gt $span -or $offset+$span -gt $bytes.Length) {throw "Bloc image hors limites : $assetName"}
        [Array]::Clear($bytes,$offset,$span)
        [Array]::Copy($assetBytes,0,$bytes,$offset,$assetBytes.Length)
      }
    }
  }
  $extra=[IO.File]::ReadAllBytes((Join-Path $patchDir ([string]$manifest.target_section_file)))
  if ((SHA256-Bytes $extra) -ne [string]$manifest.target_section_sha256) {throw 'Section de textes corrompue.'}
  $target=New-Object byte[] ($bytes.Length+$extra.Length)
  [Array]::Copy($bytes,0,$target,0,$bytes.Length)
  [Array]::Copy($extra,0,$target,$bytes.Length,$extra.Length)
  if ($target.Length -ne [int]$manifest.target_size -or (SHA256-Bytes $target) -ne [string]$manifest.target_sha256) {
    throw 'Échec de validation du jeu FR final : aucun EXE généré.'
  }
  $folderRoot=Join-Path $sourceFolder 'ReZero_After_Memories_FR_v5'
  $outDir=$folderRoot
  $counter=2
  while (Test-Path -LiteralPath $outDir) { $outDir=$folderRoot+'_'+$counter; $counter++ }
  New-Item -ItemType Directory -Path $outDir | Out-Null
  Copy-GameResources $resources $outDir
  $outExe=Join-Path $outDir ([string]$manifest.target_exe)
  [IO.File]::WriteAllBytes($outExe,$target)
  if ((SHA256-File $outExe) -ne [string]$manifest.target_sha256) {throw 'Le fichier généré est incorrect.'}
  foreach ($doc in @('LISEZ_MOI_PATCH_V5.txt','dialogues_fr_v5_comparaison.csv','CREDITS_TRADUCTION.txt')) {
    $src=Join-Path $patchDir $doc
    if (Test-Path -LiteralPath $src -PathType Leaf) {Copy-Item -LiteralPath $src -Destination $outDir}
  }
  Write-Host ''
  Write-Host 'Succès : traduction FR V5 créée et vérifiée.' -ForegroundColor Green
  Write-Host $outDir
  Write-Host ('Exécutable : '+[string]$manifest.target_exe)
  $success=$true
} catch {
  Write-Host ''
  Write-Host ('Erreur : '+$_.Exception.Message) -ForegroundColor Red
  exit 1
} finally {
  if ($null -ne $stage -and (Test-Path -LiteralPath $stage)) {
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
  }
  if (-not $success -and $null -ne $outDir -and (Test-Path -LiteralPath $outDir)) {
    Remove-Item -LiteralPath $outDir -Recurse -Force -ErrorAction SilentlyContinue
  }
}
