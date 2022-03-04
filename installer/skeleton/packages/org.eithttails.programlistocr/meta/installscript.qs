//コンストラクタ
function Component()
{
}

//コンポーネント選択のデフォルト確認
Component.prototype.isDefault = function()
{
  return true
}

//インストール動作を追加
Component.prototype.createOperations = function()
{
  try{
    // createOperationsの基本処理を実行
    component.createOperations()

    if(systemInfo.kernelType === "winnt"){
      //Readme.txt用のショートカット
      component.addOperation("CreateShortcut"
                             , "@TargetDir@/README_J.html"
                             , "@StartMenuDir@/README_J.lnk"
                             , "workingDirectory=@TargetDir@"
                             , "iconPath=%SystemRoot%/system32/SHELL32.dll"
                             , "iconId=2")
      component.addOperation("CreateShortcut"
                             , "@TargetDir@/README.html"
                             , "@StartMenuDir@/README.lnk"
                             , "workingDirectory=@TargetDir@"
                             , "iconPath=%SystemRoot%/system32/SHELL32.dll"
                             , "iconId=2")
      //実行ファイル用のショートカット
      component.addOperation("CreateShortcut"
                             , "@TargetDir@/bin/gimagereader-qt6.exe"
                             , "@StartMenuDir@/gImageReader.lnk"
                             , "workingDirectory=@TargetDir@"
                             , "iconPath=@TargetDir@/bin/gimagereader-qt6.exe"
                             , "iconId=0")

    }
  }catch(e){
    print(e)
  }
}

