# parameters
param(
  [string]$ColorMode = "System",
  [double]$Opacity = 100
)

$Opacity = $Opacity / 100.0

# Load the assembly for Windows Forms
Add-Type -AssemblyName System.Windows.Forms

Add-Type -TypeDefinition '
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

public class DPIAware
{
    public static readonly IntPtr UNAWARE              = (IntPtr) (-1);
    public static readonly IntPtr SYSTEM_AWARE         = (IntPtr) (-2);
    public static readonly IntPtr PER_MONITOR_AWARE    = (IntPtr) (-3);
    public static readonly IntPtr PER_MONITOR_AWARE_V2 = (IntPtr) (-4);
    public static readonly IntPtr UNAWARE_GDISCALED    = (IntPtr) (-5);

    [DllImport("user32.dll", EntryPoint = "SetProcessDpiAwarenessContext", SetLastError = true)]
    private static extern bool NativeSetProcessDpiAwarenessContext(IntPtr Value);

    public static void SetProcessDpiAwarenessContext(IntPtr Value)
    {
        if (!NativeSetProcessDpiAwarenessContext(Value))
        {
            throw new Win32Exception();
        }
    }
}
'

try {
    [DPIAware]::SetProcessDpiAwarenessContext([DPIAware]::UNAWARE_GDISCALED)
}
catch {
    # Write-Host "The DPI awareness context has already been set."
}


[System.Windows.Forms.Application]::EnableVisualStyles()

# Define the font
$font = New-Object System.Drawing.Font("Segoe UI", 10)

# List of font names
$global:fontNames = @( 'JetBrains Mono', 'Cascadia Code', 'Consolas', 'Cascadia Mono', 'Courier New')

# Initialize $textBoxfont as $null
$global:textBoxfont = $null

function Init-Font {
    foreach ($fontName in $global:fontNames) {
        # Try to create a Font object with the current font name
        $tfont = New-Object System.Drawing.Font($fontName, 14)

        # Check if the font is installed
        if ($tfont.FontFamily.Name -eq $fontName) {
            # If the font is installed, set $textBoxfont to the Font object and break the loop
            $global:textBoxfont = $tfont
            break
        }
    }
}

Init-Font

$font = New-Object System.Drawing.Font("Segoe UI", 10)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

$Form = New-Object system.Windows.Forms.Form
$Form.Text = "ROP Code Generator"
$Form.AutoSize = $true
$Form.Font = $global:textBoxfont
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$Form.MaximizeBox = $false
$Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

$Form.Opacity = $Opacity

# Get the AppsUseLightTheme registry key value
$theme = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme"

# setup for light mode
if ($ColorMode -eq "Light") {
    $color = [System.Drawing.SystemColors]::ButtonFace
    $txtcolor = [System.Drawing.SystemColors]::WindowText
} elseif ($ColorMode -eq "Dark") {
    $color = [System.Drawing.Color]::FromArgb(39,39,39)
    $txtcolor = [System.Drawing.Color]::White
} elseif ($ColorMode -eq "System") {
    if ($theme.AppsUseLightTheme -eq 0) {
        # Dark mode
        $color = [System.Drawing.Color]::FromArgb(39,39,39)
        $txtcolor = [System.Drawing.Color]::White
    } else {
        # Light mode
        $color = [System.Drawing.SystemColors]::ButtonFace
        $txtcolor = [System.Drawing.SystemColors]::WindowText
    }
} else {
	# invalid ColorMode option fallback to light mode
	Write-Host "Invalid -ColorMode value: '$ColorMode' Valid values are Light, Dark, or System. Defaulting to Light ColorMode"
	$color = [System.Drawing.SystemColors]::ButtonFace
	$txtcolor = [System.Drawing.SystemColors]::WindowText
}

$form.BackColor = $color

$isUserAction = $true

$macros = @("Rop_0", "Rop_DPSoon", "Rop_DPSona", "Rop_PSon", "Rop_SDPona", "Rop_DPon", "Rop_PDSxnon", "Rop_PDSaon", "Rop_SDPnaa", "Rop_PDSxon", "Rop_DPna", "Rop_PSDnaon", "Rop_SPna", "Rop_PDSnaon", "Rop_PDSonon", "Rop_Pn", "Rop_PDSona", "Rop_DSon", "Rop_SDPxnon", "Rop_SDPaon", "Rop_DPSxnon", "Rop_DPSaon", "Rop_PSDPSanaxx", "Rop_SSPxDSxaxn", "Rop_SPxPDxa", "Rop_SDPSanaxn", "Rop_PDSPaox", "Rop_SDPSxaxn", "Rop_PSDPaox", "Rop_DSPDxaxn", "Rop_PDSox", "Rop_PDSoan", "Rop_DPSnaa", "Rop_SDPxon", "Rop_DSna", "Rop_SPDnaon", "Rop_SPxDSxa", "Rop_PDSPanaxn", "Rop_SDPSaox", "Rop_SDPSxnox", "Rop_DPSxa", "Rop_PSDPSaoxxn", "Rop_DPSana", "Rop_SSPxPDxaxn", "Rop_SPDSoax", "Rop_PSDnox", "Rop_PSDPxox", "Rop_PSDnoan", "Rop_PSna", "Rop_SDPnaon", "Rop_SDPSoox", "Rop_Sn", "Rop_SPDSaox", "Rop_SPDSxnox", "Rop_SDPox", "Rop_SDPoan", "Rop_PSDPoax", "Rop_SPDnox", "Rop_SPDSxox", "Rop_SPDnoan", "Rop_PSx", "Rop_SPDSonox", "Rop_SPDSnaox", "Rop_PSan", "Rop_PSDnaa", "Rop_DPSxon", "Rop_SDxPDxa", "Rop_SPDSanaxn", "Rop_SDna", "Rop_DPSnaon", "Rop_DSPDaox", "Rop_PSDPxaxn", "Rop_SDPxa", "Rop_PDSPDaoxxn", "Rop_DPSDoax", "Rop_PDSnox", "Rop_SDPana", "Rop_SSPxDSxoxn", "Rop_PDSPxox", "Rop_PDSnoan", "Rop_PDna", "Rop_DSPnaon", "Rop_DPSDaox", "Rop_SPDSxaxn", "Rop_DPSonon", "Rop_Dn", "Rop_DPSox", "Rop_DPSoan", "Rop_PDSPoax", "Rop_DPSnox", "Rop_DPx", "Rop_DPSDonox", "Rop_DPSDxox", "Rop_DPSnoan", "Rop_DPSDnaox", "Rop_DPan", "Rop_PDSxa", "Rop_DSPDSaoxxn", "Rop_DSPDoax", "Rop_SDPnox", "Rop_SDPSoax", "Rop_DSPnox", "Rop_DSx", "Rop_SDPSonox", "Rop_DSPDSonoxxn", "Rop_PDSxxn", "Rop_DPSax", "Rop_PSDPSoaxxn", "Rop_SDPax", "Rop_PDSPDoaxxn", "Rop_SDPSnoax", "Rop_PDSxnan", "Rop_PDSana", "Rop_SSDxPDxaxn", "Rop_SDPSxox", "Rop_SDPnoan", "Rop_DSPDxox", "Rop_DSPnoan", "Rop_SDPSnaox", "Rop_DSan", "Rop_PDSax", "Rop_DSPDSoaxxn", "Rop_DPSDnoax", "Rop_SDPxnan", "Rop_SPDSnoax", "Rop_DPSxnan", "Rop_SPxDSxo", "Rop_DPSaan", "Rop_DPSaa", "Rop_SPxDSxon", "Rop_DPSxna", "Rop_SPDSnoaxn", "Rop_SDPxna", "Rop_PDSPnoaxn", "Rop_DSPDSoaxx", "Rop_PDSaxn", "Rop_DSa", "Rop_SDPSnaoxn", "Rop_DSPnoa", "Rop_DSPDxoxn", "Rop_SDPnoa", "Rop_SDPSxoxn", "Rop_SSDxPDxax", "Rop_PDSanan", "Rop_PDSxna", "Rop_SDPSnoaxn", "Rop_DPSDPoaxx", "Rop_SPDaxn", "Rop_PSDPSoaxx", "Rop_DPSaxn", "Rop_DPSxx", "Rop_PSDPSonoxx", "Rop_SDPSonoxn", "Rop_DSxn", "Rop_DPSnax", "Rop_SDPSoaxn", "Rop_SPDnax", "Rop_DSPDoaxn", "Rop_DSPDSaoxx", "Rop_PDSxan", "Rop_DPa", "Rop_PDSPnaoxn", "Rop_DPSnoa", "Rop_DPSDxoxn", "Rop_PDSPonoxn", "Rop_PDxn", "Rop_DSPnax", "Rop_PDSPoaxn", "Rop_DPSoa", "Rop_DPSoxn", "Rop_D", "Rop_DPSono", "Rop_SPDSxax", "Rop_DPSDaoxn", "Rop_DSPnao", "Rop_DPno", "Rop_PDSnoa", "Rop_PDSPxoxn", "Rop_SSPxDSxox", "Rop_SDPanan", "Rop_PSDnax", "Rop_DPSDoaxn", "Rop_DPSDPaoxx", "Rop_SDPxan", "Rop_PSDPxax", "Rop_DSPDaoxn", "Rop_DPSnao", "Rop_DSno", "Rop_SPDSanax", "Rop_SDxPDxan", "Rop_DPSxo", "Rop_DPSano", "Rop_PSa", "Rop_SPDSnaoxn", "Rop_SPDSonoxn", "Rop_PSxn", "Rop_SPDnoa", "Rop_SPDSxoxn", "Rop_SDPnax", "Rop_PSDPoaxn", "Rop_SDPoa", "Rop_SPDoxn", "Rop_DPSDxax", "Rop_SPDSaoxn", "Rop_S", "Rop_SDPono", "Rop_SDPnao", "Rop_SPno", "Rop_PSDnoa", "Rop_PSDPxoxn", "Rop_PDSnax", "Rop_SPDSoaxn", "Rop_SSPxPDxax", "Rop_DPSanan", "Rop_PSDPSaoxx", "Rop_DPSxan", "Rop_PDSPxax", "Rop_SDPSaoxn", "Rop_DPSDanax", "Rop_SPxDSxan", "Rop_SPDnao", "Rop_SDno", "Rop_SDPxo", "Rop_SDPano", "Rop_PDSoa", "Rop_PDSoxn", "Rop_DSPDxax", "Rop_PSDPaoxn", "Rop_SDPSxax", "Rop_PDSPaoxn", "Rop_SDPSanax", "Rop_SPxPDxan", "Rop_SSPxDSxax", "Rop_DSPDSanaxxn", "Rop_DPSao", "Rop_DPSxno", "Rop_SDPao", "Rop_SDPxno", "Rop_DSo", "Rop_SDPnoo", "Rop_P", "Rop_PDSono", "Rop_PDSnao", "Rop_PSno", "Rop_PSDnao", "Rop_PDno", "Rop_PDSxo", "Rop_PDSano", "Rop_PDSao", "Rop_PDSxno", "Rop_DPo", "Rop_DPSnoo", "Rop_PSo", "Rop_PSDnoo", "Rop_DPSoo", "Rop_1")

# Define the known ROPs
$knownROPs = @{
    'SRCCOPY //dest = source' = '0x00CC0000' # dest = source
    'SRCPAINT //dest = source OR dest' = '0x00EE0000' # dest = source OR dest
    'SRCAND //dest = source AND dest' = '0x00880000' # dest = source AND dest
    'SRCINVERT //dest = source XOR dest' = '0x00660000' # dest = source XOR dest
    'SRCERASE //dest = source AND (NOT dest )' = '0x00440000' # dest = source AND (NOT dest )
    'NOTSRCCOPY //dest = (NOT source)' = '0x00330000' # dest = (NOT source)
    'NOTSRCERASE //dest = (NOT src) AND (NOT dest)' = '0x00110000' # dest = (NOT src) AND (NOT dest)
    'MERGECOPY //dest = (source AND pattern)' = '0x00C00000' # dest = (source AND pattern)
    'MERGEPAINT //dest = (NOT source) OR dest' = '0x00BB0000' # dest = (NOT source) OR dest
    'PATCOPY //dest = pattern' = '0x00F00000' # dest = pattern
    'PATPAINT //dest = DPSnoo' = '0x00FB0000' # dest = DPSnoo
    'PATINVERT //dest = pattern XOR dest' = '0x005A0000' # dest = pattern XOR dest
    'DSTINVERT //dest = (NOT dest)' = '0x00550000' # dest = (NOT dest)
    'BLACKNESS //dest = BLACK' = '0x00000000' # dest = BLACK
    'WHITENESS //dest = WHITE' = '0x00FF0000' # dest = WHITE
}

function GetMacroAndKnownRop {
    param (
        [int]$index
    )

    $macroName = $macros[$index]

    # Convert the index to a hex string and pad it with zeros to get a 2-digit hex number
    $hexIndex = "{0:X2}" -f $index

    # Prepend '0x00' to the hex index to match the format of the known ROPs
    $hexIndex = '0x00' + $hexIndex + '0000'

    # Check if the hex index exists as a value in the known ROPs hashtable
    $knownRopName = $knownROPs.GetEnumerator() | Where-Object { $_.Value -eq $hexIndex } | Select-Object -ExpandProperty Name

    return $macroName, $knownRopName
}

$layoutPanel = New-Object System.Windows.Forms.TableLayoutPanel
$layoutPanel.RowCount = 3
$layoutPanel.ColumnCount = 2
$layoutPanel.AutoSize = $true
$layoutPanel.BackColor = $color

$truthTable = New-Object System.Windows.Forms.TableLayoutPanel
$truthTable.RowCount = 9
$truthTable.ColumnCount = 3
$truthTable.AutoSize = $true

$buttons = New-Object System.Windows.Forms.TableLayoutPanel
$buttons.RowCount = 9
$buttons.ColumnCount = 1
$buttons.AutoSize = $true

$ropOutputLabel = New-Object System.Windows.Forms.RichTextBox
$ropOutputLabel.Text = "ROP Output - (Rop_0) BLACKNESS //dest = BLACK"
$ropOutputLabel.ReadOnly = $true
$ropOutputLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$ropOutputLabel.ForeColor = $txtcolor

$ropOutputLabel.AutoSize = $true

$outputBox = New-Object System.Windows.Forms.TextBox
#$outputBox.ReadOnly = $true
$outputBox.AutoSize = $true
$outputBox.Text = "0x00000000"
$outputBox.ForeColor = $txtcolor
$outputBox.BackColor = $color
$outputBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$outputBox.add_TextChanged({
	$textValue = $outputBox.Text
	$mode = $true # assume hex mode
	$ropCode = $null

	if ($textValue.StartsWith("0x")) {
    		# We are in hex mode need to trim the 0x
		$textValue = $textValue.Substring(2)
	} elseif ($textValue.StartsWith("0b")) {
    		# User is inputting in binary need to trim the 0b
		$textValue = $textValue.Substring(2)
		$mode = $false
	}

	# Here we need to validate our inputs
	if ($mode) {
		# 2 characters user input either 0xAA or just AA
		if ($textValue.Length -eq 2) {
			# Extract the ROP code
			$ropCode = $textValue
		}
		# 8 characters user input either 0x00AA0000 or just 00AA0000 need to extract the AA portion
		elseif ($textValue.Length -eq 8) {
			# Extract the ROP code
			$ropCode = $textValue.Substring(2, 2)
		}
	} else {
		# For binary input, ensure there are exactly 8 characters
		if ($textValue.Length -eq 8) {
			# Convert binary to hex
			$ropCode = [Convert]::ToString([Convert]::ToInt32($textValue, 2), 16)
		}
	}

	if ($ropCode -ne $null) {
		# Convert the hex string to an integer
		$ropCodeInt = [Convert]::ToInt32($ropCode, 16)

		$macroName, $knownRopName = GetMacroAndKnownRop -index $ropCodeInt
		$ropOutputLabel.Text = "ROP Code - ($macroName) $knownRopName"

		$graphics = $ropOutputLabel.CreateGraphics()
		$size = $graphics.MeasureString($ropOutputLabel.Text, $ropOutputLabel.Font)
		$ropOutputLabel.Width = [int]$size.Width + 0

		if (-not $isUserAction) {
			return
		}

		# Convert the integer to a binary string
		$binaryRopCode = [Convert]::ToString($ropCodeInt, 2)

		$binaryRopCode = $binaryRopCode.PadLeft(8, '0')
		#for ($i = $binaryRopCode.Length - 1; $i -ge 0; $i--) {
		for ($i = 0; $i -lt $binaryRopCode.Length; $i++) {
    			# Access the button by its index in the TableLayoutPanel
   			$button = $buttons.GetControlFromPosition(0, 8-$i)  # +1 to skip the header
    			$bit = $binaryRopCode[$i]
    			if ($bit -eq '1') {
        			$button.Text = "1"
    			} else {
        			$button.Text = "0"
    			}
		}
	}
})

$copyLabel = New-Object System.Windows.Forms.Label
$copyLabel.Text = ""
$copyLabel.AutoSize = $true

$copyButton = New-Object System.Windows.Forms.Button
$copyButton.Text = "Copy "
$copyButton.AutoSize = $true
$copyButton.ForeColor = $txtcolor
$copyButton.BackColor  = $color
$copyButton.Add_Click({
    $copyButton.Text = "Copied"
    [System.Windows.Forms.Clipboard]::SetText($outputBox.Text)
    
    $timer.Start()
})

$form.Add_FormClosing({
    # When the form is closing, store the TextBox value in the script-level variable
    $script:TextBoxValue = $outputBox.Text
})

$Form.AcceptButton = $copyButton

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1500

$timer.Add_Tick({
    $copyButton.Text = "Copy"
    $timer.Stop()
})

# Create labels
$patternLabel = New-Object System.Windows.Forms.Label
$patternLabel.Text = "Pattern"
$patternLabel.AutoSize = $true
$patternLabel.ForeColor = $txtcolor

$sourceLabel = New-Object System.Windows.Forms.Label
$sourceLabel.Text = "Source"
$sourceLabel.AutoSize = $true
$sourceLabel.ForeColor = $txtcolor

$destinationLabel = New-Object System.Windows.Forms.Label
$destinationLabel.Text = "Destination"
$destinationLabel.AutoSize = $true
$destinationLabel.ForeColor = $txtcolor

$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Text = "Output"
$outputLabel.AutoSize = $true
$outputLabel.ForeColor = $txtcolor

# Determine the widest label
$maxWidth = ($patternLabel.Width, $sourceLabel.Width, $destinationLabel.Width, $outputLabel.Width | Measure-Object -Maximum).Maximum + 50

# Set all labels to the same width
$patternLabel.AutoSize = $false
$patternLabel.Width = $maxWidth
$patternLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

$sourceLabel.AutoSize = $false
$sourceLabel.Width = $maxWidth
$sourceLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

$destinationLabel.AutoSize = $false
$destinationLabel.Width = $maxWidth
$destinationLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

$outputLabel.AutoSize = $false
$outputLabel.Width = $maxWidth
$outputLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

$outputBox.Width = $maxWidth
$copyButton.Width = $maxWidth

# Add labels to the truth table
$truthTable.Controls.Add($patternLabel, 0, 0)
$truthTable.Controls.Add($sourceLabel, 1, 0)
$truthTable.Controls.Add($destinationLabel, 2, 0)
$buttons.Controls.Add($outputLabel, 0, 0)

for ($i = 0; $i -lt 8; $i++) {
    $PButton = New-Object System.Windows.Forms.Button
    $PButton.Text = [Math]::Floor($i / 4)
    #$PButton.Enabled = $false
    $PButton.AutoSize = $true
    $PButton.Width = $maxWidth
    $PButton.ForeColor = $txtcolor
    $PButton.BackColor  = $color
    $PButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $truthTable.Controls.Add($PButton, 0, $i + 1)

    $SButton = New-Object System.Windows.Forms.Button
    $SButton.Text = [Math]::Floor(($i % 4) / 2)
    #$SButton.Enabled = $false
    $SButton.AutoSize = $true
    $SButton.Width = $maxWidth
    $SButton.ForeColor = $txtcolor
    $SButton.BackColor  = $color
    $SButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $truthTable.Controls.Add($SButton, 1, $i + 1)

    $DButton = New-Object System.Windows.Forms.Button
    $DButton.Text = $i % 2
    #$DButton.Enabled = $false
    $DButton.AutoSize = $true
    $DButton.Width = $maxWidth
    $DButton.ForeColor = $txtcolor
    $DButton.BackColor  = $color
    $DButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $truthTable.Controls.Add($DButton, 2, $i + 1)

    $button = New-Object System.Windows.Forms.Button
    $button.Text = "0"
    $button.AutoSize = $true
    $button.Width = $maxWidth
    $button.ForeColor = $txtcolor
    $button.BackColor  = $color
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.Add_Click({
	$isUserAction = $false
        if ($this.Text -eq "0") {
            $this.Text = "1"
        } else {
            $this.Text = "0"
        }
        $binaryString = ($buttons.Controls | Where-Object { $_ -is [System.Windows.Forms.Button] } | ForEach-Object { $_.Text }) -join ''
        $reversedBinaryString = -join $binaryString[7..0]
        $hexValue = [Convert]::ToString([Convert]::ToInt32($reversedBinaryString, 2), 16).ToUpper()
        $dwordValue = "0x" + "0" * (4 - $hexValue.Length) + $hexValue + "0000"
        $outputBox.Text = $dwordValue
	$isUserAction = $true
    })
    $buttons.Controls.Add($button, 0, $i + 1)
}

$layoutPanel.Controls.Add($truthTable, 0, 0)
$layoutPanel.Controls.Add($buttons, 1, 0)

$layoutPanel.Controls.Add($copyLabel, 0, 1)
$layoutPanel.Controls.Add($ropOutputLabel, 0, 2)
$ropOutputLabel.BackColor = $ropOutputLabel.Parent.BackColor
$ropOutputLabel.Multiline = $false

$layoutPanel.Controls.Add($outputBox, 0, 3)
$layoutPanel.Controls.Add($copyButton, 1, 3)

$Form.Controls.Add($layoutPanel)

$graphics = $ropOutputLabel.CreateGraphics()
$size = $graphics.MeasureString($ropOutputLabel.Text, $ropOutputLabel.Font)
$ropOutputLabel.Width = [int]$size.Width

[void]$Form.ShowDialog()

"$TextBoxValue"
