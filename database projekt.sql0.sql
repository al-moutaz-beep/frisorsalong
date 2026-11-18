-- Bokningssystem för en frisörsalong
CREATE DATABASE IF NOT EXISTS frisorsalong;
USE frisorsalong;

-- Varje kund får ett eget kundnummer.
CREATE TABLE IF NOT EXISTS Kunder (
    KundID INT AUTO_INCREMENT PRIMARY KEY,
    Namn VARCHAR(100) NOT NULL,
    Epost VARCHAR(255) NOT NULL
);

-- Varje tjänst har ett namn och ett pris i kronor.
CREATE TABLE IF NOT EXISTS Tjanster (
    TjanstID INT AUTO_INCREMENT PRIMARY KEY,
    Namn VARCHAR(100) NOT NULL,
    Pris DECIMAL(8, 2) NOT NULL,
    CHECK (Pris > 0)
);

-- En bokning kopplar en kund till en tjänst.
CREATE TABLE IF NOT EXISTS Bokningar (
    BokningID INT AUTO_INCREMENT PRIMARY KEY,
    KundID INT NOT NULL,
    TjanstID INT NOT NULL,
    Datum DATE NOT NULL,
    Tid TIME NOT NULL,
    Skapad DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (KundID) REFERENCES Kunder(KundID),
    FOREIGN KEY (TjanstID) REFERENCES Tjanster(TjanstID),

    -- Bokningen gäller tidigast den dag den registreras.
    CHECK (TIMESTAMP(Datum, Tid) >= Skapad),

    -- Salongen tar emot bokningar från 09.00 till före 18.00.
    CHECK (Tid >= '09:00:00' AND Tid < '18:00:00')
);

-- Här sparas en bekräftelse för varje ny bokning.
CREATE TABLE IF NOT EXISTS Bokningslogg (
    LoggID INT AUTO_INCREMENT PRIMARY KEY,
    BokningID INT NOT NULL UNIQUE,
    Meddelande VARCHAR(150) NOT NULL,
    Skapad DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (BokningID) REFERENCES Bokningar(BokningID)
);

-- Triggern sparar en bekräftelse när en bokning skapas.
CREATE TRIGGER IF NOT EXISTS BekraftaBokning
AFTER INSERT ON Bokningar
FOR EACH ROW
    INSERT INTO Bokningslogg (BokningID, Meddelande)
    VALUES (NEW.BokningID, 'Din bokning är bekräftad.');

-- Exempeldata för redovisningen.
START TRANSACTION;

INSERT INTO Kunder (Namn, Epost)
VALUES ('Anna Svensson', 'anna@example.com');
SET @anna = LAST_INSERT_ID();

INSERT INTO Kunder (Namn, Epost)
VALUES ('Erik Larsson', 'erik@example.com');
SET @erik = LAST_INSERT_ID();

INSERT INTO Tjanster (Namn, Pris)
VALUES ('Klippning', 350.00);
SET @klippning = LAST_INSERT_ID();

INSERT INTO Tjanster (Namn, Pris)
VALUES ('Skäggtrimning', 200.00);
SET @skaggtrimning = LAST_INSERT_ID();

-- Tre bokningar skapar automatiskt tre bekräftelser.
INSERT INTO Bokningar (KundID, TjanstID, Datum, Tid)
VALUES
    (@anna, @klippning, CURRENT_DATE + INTERVAL 1 DAY, '10:00:00'),
    (@erik, @klippning, CURRENT_DATE + INTERVAL 1 DAY, '11:00:00'),
    (@anna, @skaggtrimning, CURRENT_DATE + INTERVAL 2 DAY, '14:00:00');

COMMIT;

-- Fråga 1. Hur många bokningar har varje tjänst?
SELECT
    t.Namn AS Tjanst,
    COUNT(b.BokningID) AS AntalBokningar
FROM Tjanster AS t
LEFT JOIN Bokningar AS b ON b.TjanstID = t.TjanstID
GROUP BY t.TjanstID, t.Namn
ORDER BY AntalBokningar DESC, t.Namn;

-- Fråga 2. Hur många bokningar har varje kund?
SELECT
    k.Namn AS Kund,
    COUNT(b.BokningID) AS AntalBokningar
FROM Kunder AS k
LEFT JOIN Bokningar AS b ON b.KundID = k.KundID
GROUP BY k.KundID, k.Namn
ORDER BY AntalBokningar DESC, k.Namn;

-- Visa kundens namn, bokad tid och bekräftelsen från triggern.
SELECT
    k.Namn AS Kund,
    t.Namn AS Tjanst,
    b.Datum,
    b.Tid,
    l.Meddelande AS Bekraftelse
FROM Bokningslogg AS l
JOIN Bokningar AS b ON b.BokningID = l.BokningID
JOIN Kunder AS k ON k.KundID = b.KundID
JOIN Tjanster AS t ON t.TjanstID = b.TjanstID
ORDER BY b.Datum, b.Tid;