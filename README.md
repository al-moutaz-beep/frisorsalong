# Bokningssystem för en frisörsalong

Projektet är en databas där en frisörsalong kan registrera kunder, tjänster och bokningar. När en kund bokar en tid sparas en bekräftelse automatiskt.

## Databas och struktur

Jag valde MySQL eftersom varje bokning hör till en kund och en tjänst. Jag delade upp informationen i fyra tabeller så att samma kund kan boka flera gånger utan att namn och e-post behöver sparas på nytt.

| Tabell | Innehåll |
| --- | --- |
| Kunder | Kundens ID, namn och e-postadress. |
| Tjanster | Tjänstens ID, namn och pris i kronor. |
| Bokningar | Kund, tjänst, datum, tid och när bokningen registrerades. |
| Bokningslogg | Bokningens ID, bekräftelsetext och tidpunkt för bekräftelsen. |

## Dataintegritet och säkerhet

Varje tabell har en primärnyckel. Främmande nycklar gör att en bokning bara kan sparas för en kund och en tjänst som finns i databasen.

`NOT NULL` gör viktiga fält obligatoriska. `CHECK` kräver ett positivt pris och en bokningstid från 09.00 till före 18.00. Tiden för besöket måste också vara samma som eller senare än registreringstidpunkten. `DEFAULT CURRENT_TIMESTAMP` fyller i registreringstidpunkten automatiskt.

Jag använde fiktiva kunduppgifter för att kunna visa projektet utan att dela riktiga kunders e-postadresser. Om salongen använder systemet i drift bör personalen bara ha de databasbehörigheter som behövs för arbetet.

## Test och resultat

Jag testade databasen i MySQL Workbench med två kunder och tre bokningar. Två frågor använder `JOIN` och `GROUP BY` för att räkna bokningarna per tjänst och per kund.

- Klippning fick två bokningar och skäggtrimning fick en.
- Anna Svensson hade två bokningar och Erik Larsson hade en.
- Triggern `BekraftaBokning` sparade en rad i `Bokningslogg` för varje ny bokning. Alla tre fick meddelandet ”Din bokning är bekräftad.”