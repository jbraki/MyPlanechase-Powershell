<#
    Planechase in PowerShell
    By: John Xiong

    How to load:
    Download on of the JSON files with the card data
    Download the MTG folder with card assets from main branch
    In readCard uncomment the JSON file you are using
    In changePlane, update imgPath to your MTG directory
#>

# Load Assembly to create the form and drawings
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing



# Generate a random integer between 1 and 5
# New-Variable -Name $min -Value 1 -Option Constant
# New-Variable -Name $max -Value 5 -Option Constant

#counter
$i = 0

$global:cardStack = New-Object System.Collections.ArrayList
$oldStack = @()
$global:currentCard
$global:cardCounter = 0
$global:lastcard = ""
$global:isDeckEmpty = $false
$global:diceRollCost = 0
$global:turn = 0
$global:returnToMain = $false
$global:isSpatialMerging = $false

<#
    START
    Function/Class Definitions

#>

function getData{

    # This following line is needed
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
    #$json = Get-Content -Path "five_cards_phenom.json" | ConvertFrom-Json
    $json = Get-Content -Path "IT.json" | ConvertFrom-Json
    #$json = Get-Content -Path "plane_cards.json" | ConvertFrom-Json
    #$json = Get-Content -Path "phenomenon_cards.json" | ConvertFrom-Json

    #Use this for all cards
    #$json = Get-Content -Path "all_cards.json" | ConvertFrom-Json




    foreach ($card in $json.data) {
        # "| Out-Null" The reason why $global:cardStack.Add writes out numbers is because it is returning the index of the added element in the ArrayList.
        # In PowerShell, when a method returns a value but that value is not captured or used, PowerShell automatically writes that value to the console.
        $global:cardStack.Add(($newCard = [myCard]::new($card.name, $card.oracle_text, $card.image_uris.normal, $card.type_line))) | Out-Null
        
    }
    #showStack
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Loaded $($global:cardStack.Count) cards"
    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function downloadImages{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    foreach ($card in $global:cardStack) {
        #Load the URL of image and the save destination
        $url = $card.getImgURL()
        $imgpath = "C:\temp\mtg\" + $card.getCardName() + ".jpg"

        # Download the images
        $client = New-Object System.Net.WebClient
        $client.DownloadFile($url, $imgpath)
    
    }
    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"    
}

function rotateImages{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    foreach ($card in $global:cardStack) {
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

# TODO Discard Pile

function setLastCard {
    param([string]$inputCard)

    $global:lastcard = $inputCard
}

function getLastCard {
    return $global:lastcard
}


class myCard {
    # IF ANYTHING GETS UPDATED HERE, GETCARD LINE 80 MUST BE UPDATED
    [string] $cardName
    [string] $oracleText
    [string] $imgURL
    [string] $cardType

    myCard([string] $name, [string] $text, [string] $url, [string] $cType) {
        $this.cardName = $name
        $this.oracleText = $text
        $this.imgURL = $url
        $this.cardType = $cType
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

    [string] getCardType() {
        return $this.cardType 
    }
}


function shuffleStack{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    $shuffledStack = New-Object System.Collections.ArrayList
    $originalCount = $global:cardStack.Count
    
    for ($i = 0; $i -lt $originalCount; $i++) {
        # Choose a random card, add it to Random Pile, remove selected card
        $randomIndex = Get-Random -Minimum 0 -Maximum $global:cardStack.Count
        $shuffledStack.Add($global:cardStack[$randomIndex]) | Out-Null
        $global:cardStack.RemoveAt($randomIndex)
    }

    # Re-add random pill to the oringla pill
    $global:cardStack.AddRange($shuffledStack)
    #showStack

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function showStack{
    # If you want to see every card in the cardStack in the console
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    foreach ($card in $global:cardStack) {
        $i++
        Write-Host $i
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Card Name: $($card.cardName)"
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Oracle Text: $($card.oracleText)"
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] IMG URL: $($card.imgURL)"
    }

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function getTopCard{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"


    if ($global:cardStack -ne $null){
        # Select the last card, move it to a different object, remove it from the original list
        $global:currentCard = $global:cardStack[$global:cardStack.Count - 1]
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Next Card: " $global:currentCard.getCardName()
        $global:cardStack.RemoveAt($global:cardStack.Count - 1)

        # This Triggers on Turn one because checkFirstTurn will recurisevly check
        # if a Phenomenon is on top and call this function to find the next card
        <# if($global:turn -ne 1){
            $global:cardCounter-- 
        } #>
    }
    else{  
        Write-Host "[$((Get-Date).TimeofDay) WARNING] Deck Empty!"
        $global:isDeckEmpty = $true
        
    }
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Currently $($global:cardStack.Count) cards left"

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    
}

function checkFirstTurn{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    

    # Check to see if first card is a Phenomenon, if it is, Add the card back and shuffle
    if($global:currentCard.getCardType() -eq "Phenomenon" -and $global:turn -eq 1){
        Write-Host "[$((Get-Date).TimeofDay) WARNING] Phenomenon Found on Top. RESHUFFLING"
        
        $global:cardCounter++
        # Check for infinite loop; ONLY PHENOMENON LOADED BUG
        if($global:cardCounter -gt $global:cardStack.Count){
            Write-Host "[$((Get-Date).TimeofDay) WARNING] INFINITE LOOP FOUND"
            break

        }
        else{
            $global:cardStack.Add($global:currentCard)
            shuffleStack
            getTopCard
            checkFirstTurn

        }
    }

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function changePlane {
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"    

    # Update Turn Count
    $global:turn++
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] TURN $($global:turn)"

    # Draw first card
    getTopCard

    # Check First Turn
    if($global:turn -eq 1){
        checkFirstTurn
    }
    if($global:turn -eq 2){
        # ONLY FOR TESTING Spatial Merging || Interplanar Tunnel
        $testValue = "Interplanar Tunnel"
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] TESTING FOR: $testValue"

        if($global:currentCard.getCardName() -ne $testValue){
            do{
                Write-Host "[$((Get-Date).TimeofDay) WARNING] NOT $testValue. RESHUFFLING"
                $global:cardStack.Add($global:currentCard)
                shuffleStack
                getTopCard
                if($($global:cardStack.Count) -le 0){
                    break
                }

            } while ($global:currentCard.getCardName() -ne $testValue)     
        }
    }

    $imgpath = "C:\temp\mtg\" + $global:currentCard.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath"


    # Check if the PictureBox has an image
    if($global:isDeckEmpty -eq $false){
        if ($PictureBox.Image -eq $null) {
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image Inserted"
        $PictureBox.Image = [System.Drawing.Image]::FromFile($imgPath)

        }
        else{
            # Clear Memory of old
            Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image Updated"
            $pictureBox.Image.Dispose()
            $PictureBox.Image = [System.Drawing.Image]::FromFile($imgPath)
            
        }
    }

    checkPhenomenon    

    # TODO Discard Pile
    #setLastCard -inputCard $imgPath
    #Write-Host $("Last Card was: " + (getLastCard))
    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function getPlaneCard{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    # Check to see how many planecards are left
    $planeCount = 0
    foreach ($card in $global:cardStack) {
        if($card.getCardType() -like "*Plane*"){
            $planeCount++
        }
    }

    # Grab cards only if they are Planes, if they are a Phenomenon, Add it to bottom
    # TODO This will have to get fixed, this is assuming Interplanar Tunnel still exist in the card stack, Spatial Merging requires two planes
    if($planeCount -ge 5){
        getTopCard
        if($global:currentCard.getCardType() -eq "Phenomenon"){
            Write-Host "[$((Get-Date).TimeofDay) WARNING] Phenomenon Found on Top. Adding it to the bottom"
            $global:cardStack.Insert(0,$global:currentCard)
            getPlaneCard

        }
    }
    else{
         Write-Host "[$((Get-Date).TimeofDay) WARNING] Less than 5 Planes found"

    }    

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function checkPhenomenon{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    
    if($global:currentCard.getCardName() -eq "Chaotic Aether"){
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Phenomenon Found! Entering Chaotic Aether"
        loadAC
    }
    if($global:currentCard.getCardName() -eq "Interplanar Tunnel"){
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Phenomenon Found! Entering Interplanar Tunnel"
        loadIT
    }
    
    if($global:currentCard.getCardName() -eq "Spatial Merging"){
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Phenomenon Found! Entering Spatial Merging"
        loadSM
    }


    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function loadSM{
    # When you encounter Spatial Merging, reveal cards from the top of your planar deck until you reveal two plane cards.
    # Simultaneously planeswalk to both of them. 
    # Put all other cards revealed this way on the bottom of your planar deck in any order.
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    $global:isSpatialMerging = $true

    $FormSM = New-Object System.Windows.Forms.Form
    $FormSM.Text = "Spatial Merging"
    $FormSM.Size = New-Object System.Drawing.Size(1280, 720)

    $buttonWidth = $FormSM.ClientSize.Width * 0.2  # 20% of form width
    $buttonHeight = $FormSM.ClientSize.Height * 0.1  # 10% of form height

    $buttonX = $FormSM.ClientSize.Width * 0.05  
    $buttonY = $FormSM.ClientSize.Height * 0.85  


    $buttonSM = New-Object System.Windows.Forms.Button
    $buttonSM.Location = New-Object System.Drawing.Point($buttonX, $buttonY)
    $buttonSM.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $buttonSM.Text = "Roll for $global:diceRollCost"
    $FormSM.Controls.Add($buttonSM)

    $button2X = $FormSM.ClientSize.Width * 0.75  
    $button2Y = $FormSM.ClientSize.Height * 0.85  

    $buttonSM2 = New-Object System.Windows.Forms.Button
    $buttonSM2.Location = New-Object System.Drawing.Point($button2X, $button2Y)
    $buttonSM2.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)     
    $buttonSM2.Text = "Next Player"
    $buttonSM2.Enabled = $false
    $FormSM.Controls.Add($buttonSM2)

    $button3X = $Form.ClientSize.Width * 0.4  
    $button3Y = $Form.ClientSize.Height * 0.85 

    $ButtonSM3 = New-Object System.Windows.Forms.Button
    $ButtonSM3.Location = New-Object System.Drawing.Point($button3X, $button3Y)
    $ButtonSM3.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $ButtonSM3.Text = "Force Change"
    $ButtonSM3.Enabled = $false
    $FormSM.Controls.Add($ButtonSM3)

    $PictureBoxSMWidth = $FormSM.ClientSize.Width * 0.40  
    $PictureBoxSMHeight = $FormSM.ClientSize.Height * 0.75    

    # CARD 1
    getPlaneCard
    $card1 = $global:currentCard
    $PictureBoxSMX = $FormSM.ClientSize.Width * 0.025  
    $PictureBoxSMY = $FormSM.ClientSize.Height * 0.025 
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Spatial Merging Card 1: " $card1.getCardName()
    $imgpath = "C:\temp\mtg\" + $card1.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath"

    $PictureBoxSM = New-Object System.Windows.Forms.PictureBox
    $PictureBoxSM.Location = New-Object System.Drawing.Point($PictureBoxSMX, $PictureBoxSMY)
    $PictureBoxSM.Size = New-Object System.Drawing.Size($PictureBoxSMWidth, $PictureBoxSMHeight)
    $PictureBoxSM.SizeMode = "Zoom"
    $PictureBoxSM.Image = [System.Drawing.Image]::FromFile($imgPath)


    $FormSM.Controls.Add($PictureBoxSM)

    # CARD 2
    getPlaneCard
    $card2 = $global:currentCard
    $PictureBoxSM2X = $FormSM.ClientSize.Width * 0.525  
    $PictureBoxSM2Y = $FormSM.ClientSize.Height * 0.025 
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Spatial Merging Card 2: " $card2.getCardName()
    $imgpath = "C:\temp\mtg\" + $card2.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath"

    $PictureBoxSM2 = New-Object System.Windows.Forms.PictureBox
    $PictureBoxSM2.Location = New-Object System.Drawing.Point($PictureBoxSM2X, $PictureBoxSM2Y)
    $PictureBoxSM2.Size = New-Object System.Drawing.Size($PictureBoxSMWidth, $PictureBoxSMHeight)
    $PictureBoxSM2.SizeMode = "Zoom"
    $PictureBoxSM2.Image = [System.Drawing.Image]::FromFile($imgPath)

    $buttonSM.Add_Click({
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Button Clicked"
        if($global:isDeckEmpty -eq $false){
            rollDie
            #changePlane
            $Button2.Enabled = $true

        }
        if($global:isDeckEmpty -eq $true){
            $Button.Enabled = $false
        }
        
    })

    $buttonSM2.Add_Click({
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Button2 Clicked"
        if($global:isDeckEmpty -eq $false){
            nextPlayer
            $Button2.Enabled = $false

        }
        if($global:isDeckEmpty -eq $true){
            $Button.Enabled = $false
        }
        
    })

    
    $FormSM.Controls.Add($PictureBoxSM2)

    $result = $formSM.ShowDialog()

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function loadAC{
    # Create another Form pop up with the Phenomenon Chaotic AEther
    # When you encounter Chaotic Aether, each blank roll of the planar die is a {CHAOS} roll until a player planeswalks away from a plane.
    # (Then planeswalk away from this phenomenon.)
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    
    $formAE = New-Object System.Windows.Forms.Form
    $formAE.Text = "Chaotic Aether"
    $formAE.Size = New-Object System.Drawing.Size(600, 400)

    $pictureBoxAE = New-Object System.Windows.Forms.PictureBox
    $pictureBoxAE.Location = New-Object System.Drawing.Point(10, 10)
    $pictureBoxAE.Size = New-Object System.Drawing.Size(570, 330)
    $pictureBoxAE.SizeMode = "Zoom"
    $pictureBoxAE.Image = $PictureBox.Image

    $formAE.Controls.Add($pictureBoxAE)

    $result = $formAE.Show()


    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function loadIT{
    # Create another Form pop up with the Phenomenon Interplanar Tunnel
    # When you encounter Interplanar Tunnel, reveal cards from the top of your planar deck until you reveal five plane cards.
    # Put a plane card from among them on top of your planar deck, then put the rest of the revealed cards on the bottom in a random order.
    # (Then planeswalk away from this phenomenon.)
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    $itCard = $global:currentCard
    
    $formIT = New-Object System.Windows.Forms.Form
    $formIT.Text = "Interplanar Tunnel"
    $formIT.Size = New-Object System.Drawing.Size(1280, 720) # 1600, 900 OR  1280, 720

    $pictureBoxWidth = $FormIT.ClientSize.Width * 0.32
    $pictureBoxHeight = $FormIT.ClientSize.Height * 0.32

    # CARD 1
    getPlaneCard
    $card1 = $global:currentCard
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Interplanar Tunnel Card 1: " $card1.getCardName()
    $imgpath = "C:\temp\mtg\" + $card1.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath"

    $pictureBoxIT1X = $FormIT.ClientSize.Width * 0.01
    $pictureBoxIT1Y = $FormIT.ClientSize.Height * 0.01    

    $pictureBoxIT1 = New-Object System.Windows.Forms.PictureBox
    $pictureBoxIT1.Location = New-Object System.Drawing.Point($pictureBoxIT1X, $pictureBoxIT1Y)
    $pictureBoxIT1.Size = New-Object System.Drawing.Size($pictureBoxWidth, $pictureBoxHeight)
    $pictureBoxIT1.SizeMode = "StretchImage"
    $pictureBoxIT1.Image = [System.Drawing.Image]::FromFile($imgPath)
    $pictureBoxIT1.Cursor = [System.Windows.Forms.Cursors]::Hand

    # CARD 2
    getPlaneCard 
    $card2 = $global:currentCard
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Interplanar Tunnel Card 2: " $card2.getCardName()
    $imgpath = "C:\temp\mtg\" + $card2.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath"    

    $pictureBoxIT2X = $FormIT.ClientSize.Width * 0.34
    $pictureBoxIT2Y = $FormIT.ClientSize.Height * 0.01  

    $pictureBoxIT2 = New-Object System.Windows.Forms.PictureBox
    $pictureBoxIT2.Location = New-Object System.Drawing.Point($pictureBoxIT2X, $pictureBoxIT2Y)
    $pictureBoxIT2.Size = New-Object System.Drawing.Size($pictureBoxWidth, $pictureBoxHeight)
    $pictureBoxIT2.SizeMode = "StretchImage"
    $pictureBoxIT2.Image = [System.Drawing.Image]::FromFile($imgPath)
    $pictureBoxIT2.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    # CARD 3
    getPlaneCard
    $card3 = $global:currentCard
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Interplanar Tunnel Card 3: " $card3.getCardName()
    $imgpath = "C:\temp\mtg\" + $card3.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath" 

    $pictureBoxIT3X = $FormIT.ClientSize.Width * 0.67
    $pictureBoxIT3Y = $FormIT.ClientSize.Height * 0.01  

    $pictureBoxIT3 = New-Object System.Windows.Forms.PictureBox
    $pictureBoxIT3.Location = New-Object System.Drawing.Point($pictureBoxIT3X, $pictureBoxIT3Y)
    $pictureBoxIT3.Size = New-Object System.Drawing.Size($pictureBoxWidth, $pictureBoxHeight)
    $pictureBoxIT3.SizeMode = "StretchImage"
    $pictureBoxIT3.Image = [System.Drawing.Image]::FromFile($imgPath)
    $pictureBoxIT3.Cursor = [System.Windows.Forms.Cursors]::Hand

    # CARD 4
    getPlaneCard
    $card4 = $global:currentCard
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Interplanar Tunnel Card 4: " $card4.getCardName()
    $imgpath = "C:\temp\mtg\" + $card4.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath"

    $pictureBoxIT4X = $FormIT.ClientSize.Width * 0.01
    $pictureBoxIT4Y = $FormIT.ClientSize.Height * 0.34       

    $pictureBoxIT4 = New-Object System.Windows.Forms.PictureBox
    $pictureBoxIT4.Location = New-Object System.Drawing.Point($pictureBoxIT4X, $pictureBoxIT4Y)
    $pictureBoxIT4.Size = New-Object System.Drawing.Size($pictureBoxWidth, $pictureBoxHeight)
    $pictureBoxIT4.SizeMode = "StretchImage"
    $pictureBoxIT4.Image = [System.Drawing.Image]::FromFile($imgPath)
    $pictureBoxIT4.Cursor = [System.Windows.Forms.Cursors]::Hand

    # CARD 5
    getPlaneCard
    $card5 = $global:currentCard
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Interplanar Tunnel Card 5: " $card5.getCardName()
    $imgpath = "C:\temp\mtg\" + $card5.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath" 
    
    $pictureBoxIT5X = $FormIT.ClientSize.Width * 0.34
    $pictureBoxIT5Y = $FormIT.ClientSize.Height * 0.34  

    $pictureBoxIT5 = New-Object System.Windows.Forms.PictureBox
    $pictureBoxIT5.Location = New-Object System.Drawing.Point($pictureBoxIT5X, $pictureBoxIT5Y)
    $pictureBoxIT5.Size = New-Object System.Drawing.Size($pictureBoxWidth, $pictureBoxHeight)
    $pictureBoxIT5.SizeMode = "StretchImage"
    $pictureBoxIT5.Image = [System.Drawing.Image]::FromFile($imgPath)
    $pictureBoxIT5.Cursor = [System.Windows.Forms.Cursors]::Hand

    $labelWidth = $FormIT.ClientSize.Width * 0.80
    $labelHeight = $FormIT.ClientSize.Height * 0.32
    $labelX = $FormIT.ClientSize.Width * 0.1
    $labelY = $FormIT.ClientSize.Height * 0.82
    
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point($labelX, $labelY)
    $label.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
    $label.Font = New-Object System.Drawing.Font("Arial", 18)
    $label.Text = $itCard.getOracleText()

    $formIT.Controls.Add($label)
    $formIT.Controls.Add($pictureBoxIT1)
    $formIT.Controls.Add($pictureBoxIT2)
    $formIT.Controls.Add($pictureBoxIT3)
    $formIT.Controls.Add($pictureBoxIT4)
    $formIT.Controls.Add($pictureBoxIT5)

    # When a card is pressed, pass the selected card to main form
    # and readd the other cards to the bottom

    $pictureBoxIT1.Add_Click({
        Write-Host "[$((Get-Date).TimeofDay) INFO   ]" $card1.getCardName() " selected!"
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Returning to Game"
        $global:returnToMain = $true
        $global:currentCard = $card1
        $global:cardStack.Insert(0,$card2)
        $global:cardStack.Insert(0,$card3)
        $global:cardStack.Insert(0,$card4)
        $global:cardStack.Insert(0,$card5)

        $formIT.Dispose()
        $formIT.Close()
        
    })

    $pictureBoxIT2.Add_Click({
        Write-Host "[$((Get-Date).TimeofDay) INFO   ]" $card2.getCardName() " selected!"
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Returning to Game"
        $global:returnToMain = $true
        $global:currentCard = $card2
        $global:cardStack.Insert(0,$card1)
        $global:cardStack.Insert(0,$card3)
        $global:cardStack.Insert(0,$card4)
        $global:cardStack.Insert(0,$card5)

        $formIT.Dispose()
        $formIT.Close()
        
    })

    $pictureBoxIT3.Add_Click({
        Write-Host "[$((Get-Date).TimeofDay) INFO   ]" $card3.getCardName() " selected!"
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Returning to Game"
        $global:returnToMain = $true
        $global:currentCard = $card3
        $global:cardStack.Insert(0,$card1)
        $global:cardStack.Insert(0,$card2)
        $global:cardStack.Insert(0,$card4)
        $global:cardStack.Insert(0,$card5)

        $formIT.Dispose()
        $formIT.Close()
        
    })

    $pictureBoxIT4.Add_Click({
        Write-Host "[$((Get-Date).TimeofDay) INFO   ]" $card4.getCardName() " selected!"
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Returning to Game"
        $global:returnToMain = $true
        $global:currentCard = $card4
        $global:cardStack.Insert(0,$card1)
        $global:cardStack.Insert(0,$card2)
        $global:cardStack.Insert(0,$card3)
        $global:cardStack.Insert(0,$card5)

        $formIT.Dispose()
        $formIT.Close()
        
    })

    $pictureBoxIT5.Add_Click({
        Write-Host "[$((Get-Date).TimeofDay) INFO   ]" $card5.getCardName() " selected!"
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Returning to Game"
        $global:returnToMain = $true
        $global:currentCard = $card5
        $global:cardStack.Insert(0,$card1)
        $global:cardStack.Insert(0,$card2)
        $global:cardStack.Insert(0,$card3)
        $global:cardStack.Insert(0,$card4)


        $formIT.Dispose()
        $formIT.Close()
        
    })

    $result = $formIT.ShowDialog()

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

Function rollDie{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    $global:diceRollCost++
    $Button.Text = "Roll for $global:diceRollCost"
    $randomIndex = Get-Random -Minimum 1 -Maximum 7
    
    if($randomIndex -eq 1){
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Rolled: CHANGE PLANE"
        if($global:isSpatialMerging -eq $false){
            changePlane
        }
        else{
            $global:isSpatialMerging = $false
            $formSM.Dispose()
            $formSM.Close()
            changePlane
        }
    }
    elseif($randomIndex -eq 6){
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] Rolled: CHAOS"


    }

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function nextPlayer{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    $global:diceRollCost = 0    
    $Button.Text = "Roll for $global:diceRollCost"

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function Close-Form {
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Form is closing"
    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function setPictureBox{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    
    $imgpath = "C:\temp\mtg\" + $global:currentCard.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath"
    $PictureBox.Image = [System.Drawing.Image]::FromFile($imgPath)

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}
<#
    START
    Form Definitions

#>

# TODO More Form Design
# (XXX,YYY)
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "My Test Program"
$Form.Size = New-Object System.Drawing.Size(1280, 720)
$Form.FormBorderStyle = "Fixed3D"

$buttonWidth = $Form.ClientSize.Width * 0.2  # 20% of form width
$buttonHeight = $Form.ClientSize.Height * 0.1  # 10% of form height

$buttonX = $Form.ClientSize.Width * 0.05  
$buttonY = $Form.ClientSize.Height * 0.85  

$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Point($buttonX, $buttonY)
$Button.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$Button.Text = "Roll for $global:diceRollCost"
$Form.Controls.Add($Button)

$button2X = $Form.ClientSize.Width * 0.75  
$button2Y = $Form.ClientSize.Height * 0.85 

$Button2 = New-Object System.Windows.Forms.Button
$Button2.Location = New-Object System.Drawing.Point($button2X, $button2Y)
$Button2.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$Button2.Text = "Next Player"
$Button2.Enabled = $false
$Form.Controls.Add($Button2)

$button3X = $Form.ClientSize.Width * 0.4  
$button3Y = $Form.ClientSize.Height * 0.85 

$Button3 = New-Object System.Windows.Forms.Button
$Button3.Location = New-Object System.Drawing.Point($button3X, $button3Y)
$Button3.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$Button3.Text = "Force Change"
$Button3.Enabled = $false
$Form.Controls.Add($Button3)

$PictureBoxX = $Form.ClientSize.Width * 0.01
$PictureBoxY = $Form.ClientSize.Height * 0.01

$PictureBoxWidth = $Form.ClientSize.Width * 0.95
$PictureBoxHeight = $Form.ClientSize.Height * 0.80

$PictureBox = New-Object System.Windows.Forms.PictureBox
$PictureBox.Location = New-Object System.Drawing.Point($PictureBoxX, $PictureBoxY)
$PictureBox.Size = New-Object System.Drawing.Size($PictureBoxWidth, $PictureBoxHeight)
$PictureBox.SizeMode = "Zoom"

# Call the function when the form loads
$loadHandler = {
    readCard
    shuffleStack
    changePlane
}

$refocusHandler = {
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] I've returned!"
    setPictureBox
}

$Button.Add_Click({
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Button Clicked"
    if($global:isDeckEmpty -eq $false){
        #rollDie
        changePlane
        $Button2.Enabled = $true

    }
    if($global:isDeckEmpty -eq $true){
        $Button.Enabled = $false
    }
    
})

$Button2.Add_Click({
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Button2 Clicked"
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
$form.Add_Activated($refocusHandler)
$form.Add_FormClosing({Close-Form})
$Form.ShowDialog()
