Add-Type -AssemblyName System.Runtime.WindowsRuntime
$null = [Windows.Globalization.Language, Windows.Foundation, ContentType = WindowsRuntime]
$null = [Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics.Imaging, ContentType = WindowsRuntime]
$null = [Windows.Media.Ocr.OcrEngine, Windows.Media.Ocr, ContentType = WindowsRuntime]

function Get-OcrText {
    param([string]$ImagePath)
    $absPath = (Resolve-Path $ImagePath).Path
    $file = [Windows.Storage.StorageFile]::GetFileFromPathAsync($absPath).GetAwaiter().GetResult()
    $stream = $file.OpenAsync([Windows.Storage.FileAccessMode]::Read).GetAwaiter().GetResult()
    $decoder = [Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream).GetAwaiter().GetResult()
    $bitmap = $decoder.GetSoftwareBitmapAsync().GetAwaiter().GetResult()
    $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()
    $result = $engine.RecognizeAsync($bitmap).GetAwaiter().GetResult()
    return $result.Text
}

$files = @(
    "Haliya Story\Haliya comic scene.png",
    "Haliya Story\Haliya comic scene(1).png",
    "Haliya Story\Haliya comic scene(2).png",
    "Haliya Story\Haliya comic scene(3).png",
    "Haliya Story\Haliya comic scene(4).png",
    "Haliya Story\Haliya comic scene(5).png",
    "Haliya Story\Haliya comic scene(6).png",
    "Haliya Story\Haliya comic scene(7).png",
    "Haliya Story\Haliya comic scene(8).png"
)

foreach ($f in $files) {
    $t = Get-OcrText $f
    $oneLine = $t -replace "`r`n", " " -replace "`n", " "
    Write-Output "$f -> $oneLine"
}
