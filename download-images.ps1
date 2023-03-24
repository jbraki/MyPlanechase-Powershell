$global:cardStack = New-Object System.Collections.ArrayList

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
    #$json = Get-Content -Path "SM.json" | ConvertFrom-Json
    #$json = Get-Content -Path "plane_cards.json" | ConvertFrom-Json
    $json = Get-Content -Path "phenomenon_cards.json" | ConvertFrom-Json

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

readCard
downloadImages
rotateImages