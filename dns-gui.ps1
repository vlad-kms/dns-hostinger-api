Add-Type -assembly System.Windows.Forms


$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Видемое название формы'
$main_form.Width = 100
$main_form.Height = 100
$main_form.AutoSize = $true

$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Label"
$Label.Location  = New-Object System.Drawing.Point(0,10)
$Label.AutoSize = $true
$main_form.Controls.Add($Label)

$button = New-Object System.Windows.Forms.Button
$button.Text = 'button'
$button.Location = New-Object System.Drawing.Point(160,10)
$button.Add_Click(
{
    $button.Text = "qwerty";
}
)

$main_form.Controls.Add($button)

$CheckBox = New-Object System.Windows.Forms.CheckBox
$CheckBox.Text = 'CheckBox'
$CheckBox.AutoSize = $true
$CheckBox.Checked = $true
$CheckBox.Location  = New-Object System.Drawing.Point(0,40)
$main_form.Controls.Add($CheckBox)

$RadioButton = New-Object System.Windows.Forms.RadioButton
$RadioButton.Location  = New-Object System.Drawing.Point(160,40)
$RadioButton.Text = 'RadioButton'
$RadioButton.AutoSize = $true
$main_form.Controls.Add($RadioButton)

$ComboBox = New-Object System.Windows.Forms.ComboBox
$ComboBox.DataSource = @('ComboBox','2','3','4','5','6')
$ComboBox.Location  = New-Object System.Drawing.Point(0,70)
$main_form.Controls.Add($ComboBox)

$TextBox = New-Object System.Windows.Forms.TextBox
$TextBox.Location  = New-Object System.Drawing.Point(160,70)
$TextBox.Text = 'TextBox'
$TextBox.Add_TextChanged(
{
    $button.Text = "qwerty_111";
    Write-Host "sadasdasdasd213213213 sdfsdfsdfdsf"
}
)
$main_form.Controls.Add($TextBox)

$CheckedListBox = New-Object System.Windows.Forms.CheckedListBox
$CheckedListBox.Items.ADD("CheckedListBox")
$CheckedListBox.Items.ADD("Items 2")
$CheckedListBox.Items.ADD("3")
$CheckedListBox.Location  = New-Object System.Drawing.Point(0,100)
$main_form.Controls.Add($CheckedListBox)

$GroupBox = New-Object System.Windows.Forms.GroupBox
$GroupBox.Text = "GroupBox"
$GroupBox.AutoSize = $true
$GroupBox.Location  = New-Object System.Drawing.Point(160,100)
$button2 = New-Object System.Windows.Forms.Button
$button2.Text = 'button2'
$button2.Location = New-Object System.Drawing.Point(0,30)
$GroupBox.Controls.Add($button2)
$CheckBox2 = New-Object System.Windows.Forms.CheckBox
$CheckBox2.Text = 'CheckBox2'
$CheckBox2.AutoSize = $true
$CheckBox2.Checked = $true
$CheckBox2.Location  = New-Object System.Drawing.Point(0,60)
$GroupBox.Controls.Add($CheckBox2)
$main_form.Controls.Add($GroupBox)

$ListBox = New-Object System.Windows.Forms.ListBox
$ListBox.Location  = New-Object System.Drawing.Point(0,210)
$ListBox.Items.Add('ListBox');
$ListBox.Items.Add('2');
$ListBox.Items.Add('3');
$main_form.Controls.add($ListBox)

$TabControl = New-Object System.Windows.Forms.TabControl
$TabPage1 = New-Object System.Windows.Forms.TabPage
$TabPage1.Text = 'TabPage1'
$TabLabel = New-Object System.Windows.Forms.Label
$TabLabel.Text = "TabControl"
$TabLabel.Location  = New-Object System.Drawing.Point(60,30)
$TabLabel.AutoSize = $true
$TabPage1.Controls.Add($TabLabel)
$TabPage2 = New-Object System.Windows.Forms.TabPage
$TabPage2.Text = 'TabPage2'
$TabControl.Controls.Add($TabPage1)
$TabControl.Controls.Add($TabPage2)
$TabControl.Location  = New-Object System.Drawing.Point(160,210)
$main_form.Controls.add($TabControl)

$ListView = New-Object System.Windows.Forms.ListView
$ListViewItem1 = New-Object System.Windows.Forms.ListViewItem("--=1=--")
$ListViewItem2 = New-Object System.Windows.Forms.ListViewItem("--=2=--")
$ListViewItem3 = New-Object System.Windows.Forms.ListViewItem("--=3=--")
$ListViewItem4 = New-Object System.Windows.Forms.ListViewItem("--=4=--")
$ListView.Items.Add($ListViewItem1)
$ListView.Items.Add($ListViewItem2)
$ListView.Items.Add($ListViewItem3)
$ListView.Items.Add($ListViewItem4)
$ListView.Location = New-Object System.Drawing.Point(0,320)
$main_form.Controls.add($ListView)

$TreeView = New-Object System.Windows.Forms.TreeView
$TreeViewNode=$TreeView.Nodes.Add("1")
$TreeViewNode.Nodes.Add("2")
$TreeView.Nodes.Add("3")
$TreeView.Location  = New-Object System.Drawing.Point(160,320)
$main_form.Controls.add($TreeView)

$DateTimePicker = New-Object System.Windows.Forms.DateTimePicker
$DateTimePicker.Location  = New-Object System.Drawing.Point(0,430)
$main_form.Controls.add($DateTimePicker)

$TrackBar = New-Object System.Windows.Forms.TrackBar
$TrackBar.Location  = New-Object System.Drawing.Point(200,430)
$TrackBar.Autosize = $true
$TrackBar.Value=5
$main_form.Controls.add($TrackBar)

$PictureBox = New-Object System.Windows.Forms.PictureBox
$PictureBox.Load('D:\favico.jpg')
$PictureBox.Location  = New-Object System.Drawing.Point(0,460)
$main_form.Controls.add($PictureBox)

$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Location  = New-Object System.Drawing.Point(100,460)
$ProgressBar.Value = 50
$main_form.Controls.add($ProgressBar)

$HScrollBar = New-Object System.Windows.Forms.HScrollBar
$HScrollBar.Size = New-Object System.Drawing.Size(176, 16)
$HScrollBar.Location  = New-Object System.Drawing.Point(0,510)
$main_form.Controls.add($HScrollBar)

$VScrollBar = New-Object System.Windows.Forms.VScrollBar
$VScrollBar.Size = New-Object System.Drawing.Size(16, 176)
$VScrollBar.Location  = New-Object System.Drawing.Point(380,0)
$main_form.Controls.add($VScrollBar)

$ContextMenu = New-Object System.Windows.Forms.ContextMenu
$ContextMenu.MenuItems.Add("ContextMenu")
$ContextMenu.MenuItems.Add("1")
$main_form.ContextMenu = $ContextMenu

$Menu = New-Object System.Windows.Forms.MainMenu
$menuItem1= New-Object System.Windows.Forms.menuItem
$menuItem1.Text= 'menuItem1'
$Menu.MenuItems.Add($menuItem1)
$menuItem2= New-Object System.Windows.Forms.menuItem
$menuItem2.Text= 'menuItem2'
$menuItem1.MenuItems.Add($menuItem2)
$menuItem3= New-Object System.Windows.Forms.menuItem
$menuItem3.Text= 'menuItem3'
$Menu.MenuItems.Add($menuItem3)
$main_form.Menu= $Menu

$main_form.ShowDialog()




