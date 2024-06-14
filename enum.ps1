# Función para mostrar el menú
function Show-Menu {
    param (
        [string]$Title = 'Menu de Opciones'
    )

    Write-Host "==================="
    Write-Host $Title
    Write-Host "==================="
    Write-Host "1. Buscar todos los usuarios con informacion del AD"
    Write-Host "2. Buscar todos nombres de usuarios del AD"
    Write-Host "3. Mostrar informacion de un usuario por nombre AD"
    Write-Host "4. Mostrar grupos del AD de los que un usuario del AD es miembro"
    Write-Host "5. Buscar los grupos LOCALES"
    Write-Host "6. Buscar miembros de los grupos LOCALES"
    Write-Host "7. Buscar todos los grupos del AD con toda su informacion"
    Write-Host "8. Mostrar solo los nombres (CN) de todos los grupos del AD"
    Write-Host "9. Mostrar propiedades de todos los grupos del AD (CN y DC)"
    Write-Host "10. Mostrar propiedades de un grupo del AD por su nombre (CN y DC)"
    Write-Host "Q. Salir"
}

# Función para buscar en LDAP
function LDAPSearch {
    param (
        [string]$LDAPQuery
    )

    $PDC = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().PdcRoleOwner.Name
    $DistinguishedName = ([adsi]'').distinguishedName

    $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$PDC/$DistinguishedName")
    $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher($DirectoryEntry, $LDAPQuery)

    return $DirectorySearcher.FindAll()
}

# Bucle principal para mostrar el menú y manejar la selección del usuario
do {
    Show-Menu

    Write-Host " "
    $selection = Read-Host "Seleccione una opcion"
    Write-Host " "

    switch ($selection) {
        '1' {
            # Buscar todos los usuarios
            $results = LDAPSearch -LDAPQuery "(samAccountType=805306368)"
            foreach ($result in $results) {
                $result.Properties | ForEach-Object {
                    $_
                }
                Write-Host "-------------------------------"
            }
        }
        '2' {
            # Mostrar solo los nombres (cn) de todos los grupos
            $results = LDAPSearch -LDAPQuery "(samAccountType=805306368)"
            foreach ($result in $results) {
                Write-Host $result.Properties.cn
                Write-Host "-------------------------------"
            }
        }
        '3' {
            # Mostrar información de un usuario por nombre
            $nombre_usuario = Read-Host "Ingrese el nombre del usuario a buscar"
            $usuario = LDAPSearch -LDAPQuery "(&(objectCategory=person)(objectClass=user)(cn=$nombre_usuario))"
            foreach ($result in $usuario) {
                $result.Properties | ForEach-Object {
                    $_
                }
                Write-Host "-------------------------------"
            }
        }
        '4' {
            # Mostrar grupos de los que un usuario es miembro
            $nombre_usuario = Read-Host "Ingrese el nombre del usuario a buscar"
            $usuario = LDAPSearch -LDAPQuery "(&(objectCategory=person)(objectClass=user)(cn=$nombre_usuario))"
            foreach ($result in $usuario) {
                foreach ($group in $result.Properties.memberof) {
                    Write-Host $group
                }
                Write-Host "-------------------------------"
            }
        }
        '5' {

            $results =  Get-LocalGroup
            foreach ($result in $results) {
                Write-Host $result
                Write-Host "-------------------------------"
            }

         }
        '6' {
            # Buscar todos los grupos
            $group = Read-Host "Ingrese el nombre del grupo LOCAL a buscar"
            $lgroup = Get-LocalGroupMember $group
            Write-Host $lgroup
                Write-Host "-------------------------------"
            }
        '7' {
            # Buscar todos los grupos
            $results = LDAPSearch -LDAPQuery "(objectclass=group)"
            foreach ($result in $results) {
                $result.Properties | ForEach-Object {
                    $_
                }
                Write-Host "-------------------------------"
            }
        }
        '8' {
            # Mostrar solo los nombres (cn) de todos los grupos
            $results = LDAPSearch -LDAPQuery "(objectclass=group)"
            foreach ($result in $results) {
                Write-Host $result.Properties.cn
                Write-Host "-------------------------------"
            }
        }
        '9' {
            # Mostrar propiedades de todos los grupos
            $results = LDAPSearch -LDAPQuery "(objectCategory=group)"
            foreach ($group in $results) {
                $group.Properties | ForEach-Object {
                    Write-Host $_.cn
                    Write-Host $_.member
                }
                Write-Host "-------------------------------"
            }
        }
        '10' {
            # Buscar un departamento por nombre
            $nombre_departamento = Read-Host "Ingrese el nombre del grupo a buscar"
            $department = LDAPSearch -LDAPQuery "(&(objectCategory=group)(cn=$nombre_departamento))"
            foreach ($prop in $department.Properties.member) {
                Write-Host $prop
            }
        }
        'Q' {
            Write-Host "Saliendo..."
        }
        default {
            Write-Host "Opcion no valida, intente nuevamente."
        }
    }
} while ($selection -ne 'Q')
