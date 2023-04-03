Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "My Test Program"
$Form.Size = New-Object System.Drawing.Size(965, 800)
$Form.FormBorderStyle = "Fixed3D"

$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Point(9, 700)
$Button.Size = New-Object System.Drawing.Size(100, 50)
$Button.Text = "Herp a Derp"
$Form.Controls.Add($Button)

$PictureBox = New-Object System.Windows.Forms.PictureBox
$PictureBox.Location = New-Object System.Drawing.Point(10, 10)
$PictureBox.Size = New-Object System.Drawing.Size(935, 675)
$PictureBox.SizeMode = "Zoom"

# Load the image file
$image = [System.Drawing.Image]::FromFile("C:\img\img1.jpg")

$PictureBox.Image = $image

$Button.Add_Click({
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "My Dialog Title"
    $form.Size = New-Object System.Drawing.Size(600, 400)

    $pictureBox2 = New-Object System.Windows.Forms.PictureBox
    $pictureBox2.Location = New-Object System.Drawing.Point(10, 10)
    $pictureBox2.Size = New-Object System.Drawing.Size(570, 330)
    $pictureBox2.SizeMode = "Zoom"
    $pictureBox2.Image = $PictureBox.Image

    $form.Controls.Add($pictureBox2)

    $result = $form.Show()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        # do something
    }
})

$Form.ShowDialog()
