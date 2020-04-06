# Hide PowerShell Console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  

$Form = New-Object System.Windows.Forms.Form    
$Form.Size = New-Object System.Drawing.Size(350,300)
$Form.text = "Printer Install"  

$root = "\\sgoffile01\common\ACUSCARetailIT\Printers"
$newLine = [System.Environment]::NewLine

Function Action_After_End {
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [System.Windows.Forms.MessageBox]::Show("Countdown ended" , "Info")

}

function printerInstall {
    $printer = $dropDown.SelectedItem.ToString() #populate the var with the value you selected
    $file = (Get-ChildItem -Path "$root\$printer\" -Filter *.msi).name
    $os = (gwmi win32_operatingsystem).osarchitecture.Substring(0,2)

    if ($os -eq "32") {
        $os = "86"
    }

    $install = $file | where {$_ -like "*$os.msi"}

    $results.text="Installing $printer software $install"

    $code = (Start-Process "$root\$printer\$install" -wait -PassThru).ExitCode
    if ($code -eq "0") {
    $results.Text = "Install Successful"
    }
    else {
    $results.text = "Install Failed Error Code: $code"
    }

} 

$dropDown = New-Object System.Windows.Forms.ComboBox
$dropDown.Location = New-Object System.Drawing.Size(20,50) 
$dropDown.Size = New-Object System.Drawing.Size(180,20) 
$dropDown.DropDownHeight = 200 
$Form.Controls.Add($dropDown) 

$printerlist=@((Get-ChildItem -Path $root).name)

foreach ($print in $printerlist) {
    $dropDown.Items.Add($print)
}

$results = New-Object System.Windows.Forms.TextBox 
$results.Location = New-Object System.Drawing.Size(10,125) 
$results.Size = New-Object System.Drawing.Size(315,100) 
$results.MultiLine = $True 
$Form.Controls.Add($results) 

$install = New-Object System.Windows.Forms.Button 
$install.Location = New-Object System.Drawing.Size(225,47) 
$install.Size = New-Object System.Drawing.Size(85,25) 
$install.Text = "Install" 
$install.Add_Click({printerInstall}) 
$Form.Controls.Add($install)

$modelLabel = New-Object System.Windows.Forms.Label
$modelLabel.Location = New-Object System.Drawing.Point(20,20)
$modelLabel.Size = New-Object System.Drawing.Size(280,20)
$modelLabel.Text = 'Select the model of printer:'
$form.Controls.Add($modelLabel) 

$resultsLabel = New-Object System.Windows.Forms.Label
$resultsLabel.Location = New-Object System.Drawing.Point(15,100)
$resultsLabel.Size = New-Object System.Drawing.Size(280,20)
$resultsLabel.Text = 'Status:'
$form.Controls.Add($resultsLabel) 

# Show form
$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()