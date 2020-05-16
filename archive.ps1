$root = ($pwd).Path
$cmd = $false
$sumFormat = "File: {0}`r`nSize: {1} bytes`r`nModified: {2}`r`n{3}: {4}"
$dateFormat = 'dddd, MMMM d, yyyy, h:mm:ss tt'

function Print-Usage {
    if ($cmd){
        Write-Host "调用指令: archive [param]"
        Write-Host "param 可填入目录名称, 空格分隔, 如目录内有空格, 需要用引号包裹;"
        Write-Host "或者选择以下运行参数, 执行操作"
    } else {
        Write-Host "根据提示输入目录名称, 单次只能填入一个, 目录可包含空格;"
        Write-Host "或者选择以下运行参数, 执行操作"
        Write-Host "-e: 退出"
    }
    Write-Host "-a: 逐个打包当前路径下所有目录"
    Write-Host "-h: 打印帮助信息`n"
}

function Zip-Release {
    param($dirName)
    $dir = "$($root)\$($dirName)"
    $zipName = "$($dirName).zip"
    $zipPath = "$($dir)\$($zipName)"
    $sumName = "$($dirName).sha256"
    $sumPath = "$($dir)\$($sumName)"
    try {
        Compress-Archive -Path "$($dir)\*.ass","$($dir)\*.md","$($root)\LICENSE" -Force -DestinationPath $zipPath
        $fileInfo = Get-Item -Path $zipPath
        $sum = Get-FileHash $zipPath -Algorithm SHA256
        ($sumFormat -f $zipName, $fileInfo.Length, (Get-Date -Date $fileInfo.LastWriteTime -Format $dateFormat), $sum.Algorithm, $sum.Hash) | 
            Out-File $sumPath
        Write-Host "$($dirName) 打包完成"
    } catch {
        Write-Host "$($dirName) 打包失败, 错误信息"
        $PSItem
    }
}

function Do-Input {
    for (;;) {
        Write-Host '输入待打包目录名或运行参数'
        $in = Read-Host
        Switch ($in){
            '-a' {Do-All}
            '-h' {Print-Usage}
            '-e' {Exit}
            default {Zip-Release $in}
         }
    }
}

function Do-Args {
    param($list)
    foreach ($i in $list){
        Zip-Release $i
    }
}

function Do-All {
    $all = Get-ChildItem -Path $root -Name -Exclude *.md,*.ps1,font,LICENSE
    Do-Args $all
}

if (0 -eq $args.Length){
    Do-Input
} else {
    $cmd = $true
    Switch($args[0]){
    '-a' {Do-All}
    '-h' {Print-Usage}
    default {Do-Args $args}
    }
}