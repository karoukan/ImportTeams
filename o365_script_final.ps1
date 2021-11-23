$Cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -Authentication Basic –AllowRedirection
Import-PSSession $Session
Import-Module msonline
Get-Command –Module msonline
Connect-msolservice -Credential $Cred

#Création des groupes
$Liste = Import-CSV .\test_import_mb.csv -Delimiter ';' | Select -Unique Groupe, GroupEmail

foreach ($objetsListe in $Liste) {
    $Groupe = $objetsListe.Groupe
    $GroupEmail = $objetsListe.GroupEmail

    $existant = New-UnifiedGroup -DisplayName $Groupe -EmailAddresses $GroupEmail -AccessType Private
    if ($existant -ne $NULL)
    {
        Write-Host "Le groupe $($Groupe) a été créé !" -ForegroundColor Green
    }
    else
    {
        Write-Host "Le groupe $($Groupe) existe déjà !" -ForegroundColor Red
        $Groupe | Out-File group.txt -Append # Ecriture des groupes en erreur
    }
}

#Importation des utilisateurs dans les groupes créés
Import-CSV .\test_import_mb.csv -Delimiter ';' | ForEach-Object {
        #Ajout des membres du groupes
        Add-UnifiedGroupLinks -Identity $_.Groupe -LinkType Members -Links $_.Email

        Write-Host "L'utilisateur : $($_.Email) a bien été ajouté au groupe : $($_.Groupe) !" -ForegroundColor Green
}
