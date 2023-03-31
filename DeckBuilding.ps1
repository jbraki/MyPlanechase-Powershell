#$json = Get-Content -Path "one_card.json" | ConvertFrom-Json
#$json = Get-Content -Path "five_cards.json" | ConvertFrom-Json
#$json = Get-Content -Path "plane_cards.json" | ConvertFrom-Json
$i = 0

$cardStack = New-Object System.Collections.ArrayList

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


function readCard{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    #CHOOSE ONE
    #$json = Get-Content -Path "one_card.json" | ConvertFrom-Json
    $json = Get-Content -Path "five_cards.json" | ConvertFrom-Json
    #$json = Get-Content -Path "plane_cards.json" | ConvertFrom-Json
    #$json = Get-Content -Path "phenomenon_cards.json" | ConvertFrom-Json


    foreach ($card in $json.data) {
        # $i++
        # Write-Host $i
        # Write-Host "Name: $($card.name)"
        # Write-Host "Oracle Text: $($card.oracle_text)"
        # Write-Host "IMG URL: $($card.image_uris.normal)"

        # "| Out-Null" The reason why $cardStack.Add writes out numbers is because it is returning the index of the added element in the ArrayList.
        # In PowerShell, when a method returns a value but that value is not captured or used, PowerShell automatically writes that value to the console.
        $cardStack.Add(($newCard = [myCard]::new($card.name, $card.oracle_text, $card.image_uris.normal))) | Out-Null
        

    }
    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

function shuffleStack{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    Write-Host "****************SHUFFLING****************"

    $shuffledStack = New-Object System.Collections.ArrayList
    $originalCount = $cardStack.Count
    
    for ($i = 0; $i -lt $originalCount; $i++) {
        $randomIndex = Get-Random -Minimum 0 -Maximum $cardStack.Count
        $shuffledStack.Add($cardStack[$randomIndex])  | Out-Null
        $cardStack.RemoveAt($randomIndex)
    }
    $cardStack.AddRange($shuffledStack)

    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

}


function showStack{
    Write-Host "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    foreach ($card in $cardStack) {
        Write-Host "Card Name: $($card.cardName)"
        Write-Host "Oracle Text: $($card.oracleText)"
        Write-Host "IMG URL: $($card.imgURL)"
    }
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

        # Dispose the image object
        $image.Dispose()
    
    }
    Write-Host "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

}

readCard
#showStack
#shuffleStack
#showStack
#downloadImages
#rotateImages

#$currentCard = $cardStack[$cardStack.Count - 1]
#$cardStack.RemoveAt($cardStack.Count - 1)
#Write-Host "Card Name: $($currentCard.cardName)"
#Write-Host "Oracle Text: $($currentCard.oracleText)"
#Write-Host "IMG URL: $($currentCard.imgURL)"

