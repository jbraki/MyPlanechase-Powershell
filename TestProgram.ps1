<#
    Planechase in PowerShell
    By: John Xiong

    How to load:
    Download on of the JSON files with the card data
    Download the MTG folder with card assets from main branch
    In readCard uncomment the JSON file you are using
    In changePlane, update imgPath to your MTG directory
#>

#Load Assembly to create the form and drawings
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing



# Generate a random integer between 1 and 5
# New-Variable -Name $min -Value 1 -Option Constant
# New-Variable -Name $max -Value 5 -Option Constant

#counter
$i = 0

$cardStack = New-Object System.Collections.ArrayList
$oldStack = @()
$global:currentCard
$global:cardCounter = 0
$global:lastcard = ""
$global:isDeckEmpty = $false
$global:diceRollCost = 0

<#
    START
    Function/Class Definitions

#>

function getData{

    #This following line is needed=
    #Install-Module -Name Invoke-RestMethod

    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    


    # Set the URL for the Scryfall API request
    $url = "https://api.scryfall.com/cards/search?q=t%3Aplane"
    #$url = "https://api.scryfall.com/cards/search?q=t%3Aphenomenon"

    # Send an HTTPS GET request to the URL and convert the response to JSON format
    $response = Invoke-RestMethod -Uri $url -Method Get | Select-Object -Property data | ConvertTo-Json -Depth 100

    # Save the JSON response to a file
    $response | Out-File -FilePath "plane_cards.json"

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function readCard{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    #CHOOSE ONE
    #$json = Get-Content -Path "one_card.json" | ConvertFrom-Json
    $json = Get-Content -Path "five_cards.json" | ConvertFrom-Json
    #$json = Get-Content -Path "plane_cards.json" | ConvertFrom-Json
    #$json = Get-Content -Path "phenomenon_cards.json" | ConvertFrom-Json

    #Use this for all cards
    #$json = Get-Content -Path "all_cards.json" | ConvertFrom-Json




    foreach ($card in $json.data) {
        $global:cardCounter++
        # "| Out-Null" The reason why $cardStack.Add writes out numbers is because it is returning the index of the added element in the ArrayList.
        # In PowerShell, when a method returns a value but that value is not captured or used, PowerShell automatically writes that value to the console.
        $cardStack.Add(($newCard = [myCard]::new($card.name, $card.oracle_text, $card.image_uris.normal))) | Out-Null
        
    }
    #showStack
    write-Host "Loaded $global:cardCounter cards"
    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function downloadImages{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    foreach ($card in $cardStack) {
        #Load the URL of image and the save destination
        $url = $card.getImgURL()
        $imgpath = "C:\temp\mtg\" + $card.getCardName() + ".jpg"

        #Download the images
        $client = New-Object System.Net.WebClient
        $client.DownloadFile($url, $imgpath)
    
    }
    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"    
}

function rotateImages{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    foreach ($card in $cardStack) {
        $imgpath = "C:\temp\mtg\" + $card.getCardName() + ".jpg"

        # Load the image from file
        $image = [System.Drawing.Image]::FromFile($imgpath)

        # Rotate the image by 90 degrees clockwise
        $image.RotateFlip("Rotate90FlipNone")

        # Save the rotated image back to file
        $image.Save($imgpath)

        # Dispose the image object to free memory
        $image.Dispose()
    
    }
    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

}

#TODO Discard Pile
function setLastCard {
    param([string]$inputCard)

    $global:lastcard = $inputCard
}

function getLastCard {
    return $global:lastcard
}

class myCard {
    [string] $cardName
    [string] $oracleText
    [string] $imgURL

    myCard([string] $name, [string] $text, [string] $url) {
        $this.cardName = $name
        $this.oracleText = $text
        $this.imgURL = $url
    }

    [string] getCardName() {
        return $this.cardName 
    }

    [string] getOracleText() {
        return $this.oracleText 
    }

    [string] getImgURL() {
        return $this.imgURL 
    }
}


function shuffleStack{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    $shuffledStack = New-Object System.Collections.ArrayList
    $originalCount = $cardStack.Count
    
    for ($i = 0; $i -lt $originalCount; $i++) {
        #Choose a random card, add it to Random Pile, remove selected card
        $randomIndex = Get-Random -Minimum 0 -Maximum $cardStack.Count
        $shuffledStack.Add($cardStack[$randomIndex]) | Out-Null
        $cardStack.RemoveAt($randomIndex)
    }

    #Re-add random pill to the oringla pill
    $cardStack.AddRange($shuffledStack)
    #showStack

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function showStack{
    #If you want to see every card in the cardStack in the console
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    foreach ($card in $cardStack) {
        $i++
        Write-Host $i
        Write-Host "Card Name: $($card.cardName)"
        Write-Host "Oracle Text: $($card.oracleText)"
        Write-Host "IMG URL: $($card.imgURL)"
    }

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function getTopCard{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    if ($cardStack -ne $null){
        $global:cardCounter--
        

        #Select the last card, move it to a different object, remove it from the original list
        $global:currentCard = $cardStack[$cardStack.Count - 1]
        Write-Host "Next Card: " $global:currentCard.getCardName()
        $cardStack.RemoveAt($cardStack.Count - 1)

    }
    else{  
        Write-Host "[$((Get-Date).TimeofDay) WARNING] Deck Empty!"
        $global:isDeckEmpty = $true
        
    }
    Write-Host "Currently $global:cardCounter cards left"

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    
}

function changePlane {
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    getTopCard
    $imgpath = "C:\temp\mtg\" + $global:currentCard.getCardName() + ".jpg"
    Write-Host "Image path is: $imgPath"


    # Check if the PictureBox has an image
    if($global:isDeckEmpty -eq $false){
        if ($PictureBox.Image -eq $null) {
        Write-Host "Image Inserted"
        $PictureBox.Image = [System.Drawing.Image]::FromFile($imgPath)

        }
        else{
            #Clear Memory of old
            Write-Host "Image Updated"
            $pictureBox.Image.Dispose()
            $PictureBox.Image = [System.Drawing.Image]::FromFile($imgPath)
            
        }
    }


    #TODO Discard Pile
    #setLastCard -inputCard $imgPath
    #Write-Host $("Last Card was: " + (getLastCard))
    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

Function rollDie{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    $global:diceRollCost++
    $Button.Text = "Roll for $global:diceRollCost"
    $randomIndex = Get-Random -Minimum 1 -Maximum 7
    if($randomIndex -eq 1){
        Write-Host "Rolled: CHANGE PLANE"
        changePlane
    }
    elseif($randomIndex -eq 6){
        Write-Host "Rolled: CHAOS"


    }

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function nextPlayer{
    $global:diceRollCost = 0    
    $Button.Text = "Roll for $global:diceRollCost"
}

function Close-Form {
    Write-Host "Form is closing"
}

<#
    START
    Form Definitions

#>

#TODO More Form Design
# (XXX,YYY)
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "My Test Program"
$Form.Size = New-Object System.Drawing.Size(965, 800)
$Form.FormBorderStyle = "Fixed3D"

$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Point(9, 700)
$Button.Size = New-Object System.Drawing.Size(100, 50)
$Button.Text = "Roll for $global:diceRollCost"
$Form.Controls.Add($Button)

$Button2 = New-Object System.Windows.Forms.Button
$Button2.Location = New-Object System.Drawing.Point(846, 700)
$Button2.Size = New-Object System.Drawing.Size(100, 50)
$Button2.Text = "Next Player"
$Button2.Enabled = $false
$Form.Controls.Add($Button2)

$PictureBox = New-Object System.Windows.Forms.PictureBox
$PictureBox.Location = New-Object System.Drawing.Point(10, 10)
$PictureBox.Size = New-Object System.Drawing.Size(935, 675)
$PictureBox.SizeMode = "Zoom"

# Call the function when the form loads
$loadHandler = {
    readCard
    shuffleStack
    changePlane
}

$Button.Add_Click({
    Write-Host "Button Clicked"
    if($global:isDeckEmpty -eq $false){
        rollDie
        $Button2.Enabled = $true

    }
    if($global:isDeckEmpty -eq $true){
        $Button.Enabled = $false
    }
    
})

$Button2.Add_Click({
    Write-Host "Button Clicked"
    if($global:isDeckEmpty -eq $false){
        nextPlayer
        $Button2.Enabled = $false

    }
    if($global:isDeckEmpty -eq $true){
        $Button.Enabled = $false
    }
    
})

$Form.Controls.Add($PictureBox)
$form.Add_Load($loadHandler)
$form.Add_FormClosing({Close-Form})
$Form.ShowDialog()
