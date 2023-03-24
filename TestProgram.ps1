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
#$global:cardCounter = 0
$global:lastcard = ""
$global:isDeckEmpty = $false
$global:diceRollCost = 0
$global:turn = 0
$global:returnToMain = $false

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
    $json = Get-Content -Path "SM.json" | ConvertFrom-Json
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
        $global:cardStack.Add($global:currentCard)
        shuffleStack
        getTopCard
        checkFirstTurn

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
        # ONLY FOR TESTING
        Write-Host "[$((Get-Date).TimeofDay) INFO   ] TESTING FOR: Spatial Merging"

        if($global:currentCard.getCardName() -ne "Spatial Merging"){
            do{
                Write-Host "[$((Get-Date).TimeofDay) WARNING] NOT Spatial Merging. RESHUFFLING"
                $global:cardStack.Add($global:currentCard)
                shuffleStack
                getTopCard
                if($($global:cardStack.Count) -le 0){
                    break
                }

            } while ($global:currentCard.getCardName() -ne "Spatial Merging")     
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

    $FormSM = New-Object System.Windows.Forms.Form
    $FormSM.Text = "Spatial Merging"
    $FormSM.Size = New-Object System.Drawing.Size(1200, 800)

    $buttonWidth = $FormSM.ClientSize.Width * 0.2  # 20% of form width
    $buttonHeight = $FormSM.ClientSize.Height * 0.1  # 10% of form height

    $buttonX = $FormSM.ClientSize.Width * 0.05  
    $buttonY = $FormSM.ClientSize.Height * 0.85  


    $ButtonSM = New-Object System.Windows.Forms.Button
    $ButtonSM.Location = New-Object System.Drawing.Point($buttonX, $buttonY)
    $ButtonSM.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $ButtonSM.Text = "Roll for $global:diceRollCost"
    $FormSM.Controls.Add($ButtonSM)

    $button2X = $FormSM.ClientSize.Width * 0.75  
    $button2Y = $FormSM.ClientSize.Height * 0.85  

    $ButtonSM2 = New-Object System.Windows.Forms.Button
    $ButtonSM2.Location = New-Object System.Drawing.Point($buttonX, $buttonY)
    $ButtonSM2.Size = New-Object System.Drawing.Size($button2Width, $button2Height)
    $ButtonSM2.Text = "Next Player"
    $ButtonSM2.Enabled = $false
    $FormSM.Controls.Add($ButtonSM2)

    # CARD 1
    getPlaneCard
    $card1 = $global:currentCard
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Spatial Merging Card 1: " $card1.getCardName()
    $imgpath = "C:\temp\mtg\" + $card1.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath"

    $PictureBoxSM = New-Object System.Windows.Forms.PictureBox
    $PictureBoxSM.Location = New-Object System.Drawing.Point(10, 10)
    $PictureBoxSM.Size = New-Object System.Drawing.Size(570, 330)
    $PictureBoxSM.SizeMode = "Zoom"
    $PictureBoxSM.Image = [System.Drawing.Image]::FromFile($imgPath)


    $FormSM.Controls.Add($PictureBoxSM)

    # CARD 2
    getPlaneCard
    $card2 = $global:currentCard
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Spatial Merging Card 2: " $card2.getCardName()
    $imgpath = "C:\temp\mtg\" + $card2.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath"

    $PictureBoxSM2 = New-Object System.Windows.Forms.PictureBox
    $PictureBoxSM2.Location = New-Object System.Drawing.Point(590, 10)
    $PictureBoxSM2.Size = New-Object System.Drawing.Size(570, 330)
    $PictureBoxSM2.SizeMode = "Zoom"
    $PictureBoxSM2.Image = [System.Drawing.Image]::FromFile($imgPath)

    
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
    $formIT.Size = New-Object System.Drawing.Size(1450,800)

    # CARD 1
    getPlaneCard
    $card1 = $global:currentCard
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Interplannar Tunnel Card 1: " $card1.getCardName()
    $imgpath = "C:\temp\mtg\" + $card1.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath"

    $pictureBoxIT1 = New-Object System.Windows.Forms.PictureBox
    $pictureBoxIT1.Location = New-Object System.Drawing.Point(10, 10)
    $pictureBoxIT1.Size = New-Object System.Drawing.Size(475, 270)
    $pictureBoxIT1.SizeMode = "Zoom"
    $pictureBoxIT1.Image = [System.Drawing.Image]::FromFile($imgPath)
    $pictureBoxIT1.Cursor = [System.Windows.Forms.Cursors]::Hand

    # CARD 2
    getPlaneCard
    $card2 = $global:currentCard
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Interplannar Tunnel Card 2: " $card2.getCardName()

    $imgpath = "C:\temp\mtg\" + $card2.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath"    

    $pictureBoxIT2 = New-Object System.Windows.Forms.PictureBox
    $pictureBoxIT2.Location = New-Object System.Drawing.Point(475, 10)
    $pictureBoxIT2.Size = New-Object System.Drawing.Size(475, 270)
    $pictureBoxIT2.SizeMode = "Zoom"
    $pictureBoxIT2.Image = [System.Drawing.Image]::FromFile($imgPath)
    $pictureBoxIT2.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    # CARD 3
    getPlaneCard
    $card3 = $global:currentCard
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Interplannar Tunnel Card 3: " $card3.getCardName()
    $imgpath = "C:\temp\mtg\" + $card3.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath" 

    $pictureBoxIT3 = New-Object System.Windows.Forms.PictureBox
    $pictureBoxIT3.Location = New-Object System.Drawing.Point(950, 10)
    $pictureBoxIT3.Size = New-Object System.Drawing.Size(475, 270)
    $pictureBoxIT3.SizeMode = "Zoom"
    $pictureBoxIT3.Image = [System.Drawing.Image]::FromFile($imgPath)
    $pictureBoxIT3.Cursor = [System.Windows.Forms.Cursors]::Hand

    # CARD 4
    getPlaneCard
    $card4 = $global:currentCard
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Interplannar Tunnel Card 4: " $card4.getCardName()
    $imgpath = "C:\temp\mtg\" + $card4.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath"     

    $pictureBoxIT4 = New-Object System.Windows.Forms.PictureBox
    $pictureBoxIT4.Location = New-Object System.Drawing.Point(10, 290)
    $pictureBoxIT4.Size = New-Object System.Drawing.Size(475, 270)
    $pictureBoxIT4.SizeMode = "Zoom"
    $pictureBoxIT4.Image = [System.Drawing.Image]::FromFile($imgPath)
    $pictureBoxIT4.Cursor = [System.Windows.Forms.Cursors]::Hand

    # CARD 5
    getPlaneCard
    $card5 = $global:currentCard
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Interplannar Tunnel Card 5: " $card5.getCardName()
    $imgpath = "C:\temp\mtg\" + $card5.getCardName() + ".jpg"
    Write-Host "[$((Get-Date).TimeofDay) INFO   ] Image path is: $imgPath" 
    

    $pictureBoxIT5 = New-Object System.Windows.Forms.PictureBox
    $pictureBoxIT5.Location = New-Object System.Drawing.Point(475, 290)
    $pictureBoxIT5.Size = New-Object System.Drawing.Size(475, 270)
    $pictureBoxIT5.SizeMode = "Zoom"
    $pictureBoxIT5.Image = [System.Drawing.Image]::FromFile($imgPath)
    $pictureBoxIT5.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(100, 600)
    $label.Size = New-Object System.Drawing.Size(1200, 150)
    $label.Font = New-Object System.Drawing.Font("Arial", 20)
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
        changePlane
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
