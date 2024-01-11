CREATE TABLE Specialty (
    SpecialtyID INT PRIMARY KEY,
    SpecialtyName VARCHAR(255) NOT NULL
);

CREATE TABLE Diagnosis (
    DiagnosisID INT PRIMARY KEY,
    DiagnosisName VARCHAR(255) NOT NULL
);

CREATE TABLE Doctor (
    DoctorID INT PRIMARY KEY,
    SpecialtyID INT,
    Name VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    CONSTRAINT fk_specialty FOREIGN KEY (SpecialtyID) REFERENCES Specialty(SpecialtyID)
);

CREATE TABLE Patient (
    PatientID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    EGN VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE Treatment (
    TreatmentID INT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    TreatmentDate DATE,
    Duration INT,
    Diagnosis VARCHAR(255),
    CONSTRAINT fk_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT unique_treatment_per_patient UNIQUE (PatientID, TreatmentDate)
);


INSERT INTO Specialty (SpecialtyID, SpecialtyName)
VALUES (1, 'Cardiology');

INSERT INTO Diagnosis (DiagnosisID, DiagnosisName)
VALUES (1, 'Heart Disease');

INSERT INTO Diagnosis (DiagnosisID, DiagnosisName)
VALUES (2, 'Broken leg');

INSERT INTO Doctor (DoctorID, SpecialtyID, Name, Phone)
VALUES (1, 1, 'Dr. Smith', '123-456-7890');

INSERT INTO Doctor (DoctorID, SpecialtyID, Name, Phone)
VALUES (2, 1, 'Dr. Petrov', '123-456-7895');

INSERT INTO Patient (PatientID, Name, EGN)
VALUES (1, 'John Doe', '1234567890');

INSERT INTO Patient (PatientID, Name, EGN)
VALUES (2, 'Ivan Petrov', '1234567750');

INSERT INTO Treatment (TreatmentID, PatientID, DoctorID, TreatmentDate, Duration, Diagnosis)
VALUES (1, 1, 1, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 7, 'Routine checkup');


UPDATE Patient SET Name = 'New Name' WHERE PatientID = 1;

SELECT * FROM Treatment WHERE PatientID = (SELECT PatientID FROM Patient WHERE Name = '&name');

SELECT * FROM Treatment WHERE DoctorID = (SELECT DoctorID FROM Doctor WHERE Name = '&doctor_name'); -- spravki

SELECT * FROM Treatment WHERE Diagnosis = '&diagnosis_name';

SELECT * FROM Treatment WHERE DoctorID = '&id' ORDER BY Diagnosis;

SELECT * FROM Treatment WHERE PatientID = '&id' ORDER BY TreatmentDate;

SELECT * FROM Treatment WHERE TreatmentDate BETWEEN '2023-01-01' AND '2023-01-31';

SELECT * FROM Diagnosis;

SELECT * FROM Doctor;
SELECT * FROM Treatment WHERE DoctorID = '&id';

SELECT * FROM Patient;
SELECT * FROM Treatment WHERE PatientEGN = '&egn';



CREATE OR REPLACE PROCEDURE InsertSpecialty (p_SpecialtyID IN Specialty.SpecialtyID%TYPE, 
                                             p_SpecialtyName IN Specialty.SpecialtyName%TYPE) 
AS
BEGIN
    INSERT INTO Specialty (SpecialtyID, SpecialtyName) VALUES (p_SpecialtyID, p_SpecialtyName);
END;
/

EXEC InsertSpecialty('&id', '&name');
--procedura
CREATE OR REPLACE PROCEDURE UpdateDoctor (p_DoctorID IN Doctor.DoctorID%TYPE, 
                                          p_SpecialtyID IN Doctor.SpecialtyID%TYPE,  
                                          p_Name IN Doctor.Name%TYPE, 
                                          p_Phone IN Doctor.Phone%TYPE) 
AS
BEGIN
    UPDATE Doctor 
    SET SpecialtyID = p_SpecialtyID, Name = p_Name, Phone = p_Phone
    WHERE DoctorID = p_DoctorID;
END UpdateDoctor;
/

EXEC UpdateDoctor('&docID', '&specID', '&name', '&phone');

CREATE OR REPLACE PROCEDURE InsertDiagnosis (p_DiagnosisID IN Diagnosis.DiagnosisID%TYPE, 
                                             p_DiagnosisName IN Diagnosis.DiagnosisName%TYPE) 
AS
BEGIN
    INSERT INTO Diagnosis (DiagnosisID, DiagnosisName) VALUES (p_DiagnosisID, p_DiagnosisName);
END InsertDiagnosis;
/
EXEC InsertDiagnosis('&id', '&diagnosename');

CREATE OR REPLACE PROCEDURE UpdatePatient (p_PatientID IN Patient.PatientID%TYPE, 
                                           p_Name IN Patient.Name%TYPE, 
                                           p_EGN IN Patient.EGN%TYPE) 
AS
BEGIN
    UPDATE Patient 
    SET Name = p_Name, EGN = p_EGN
    WHERE PatientID = p_PatientID;
END UpdatePatient;
/
EXEC UpdatePatient('&patID', '&patName', '&patEGN');

CREATE OR REPLACE PROCEDURE ShowTreatmentsForDoctor(p_DoctorID IN Doctor.DoctorID%TYPE) IS
    CURSOR treatments_cursor IS 
        SELECT t.TreatmentID, t.PatientID, t.TreatmentDate, t.Diagnosis 
        FROM Treatment t
        WHERE t.DoctorID = p_DoctorID;

    treatment_record treatments_cursor%ROWTYPE;
BEGIN
    OPEN treatments_cursor;

    LOOP
        FETCH treatments_cursor INTO treatment_record;
        EXIT WHEN treatments_cursor%NOTFOUND;


        DBMS_OUTPUT.PUT_LINE('Treatment ID: ' || treatment_record.TreatmentID ||
                             ', Patient ID: ' || treatment_record.PatientID ||
                             ', Date: ' || treatment_record.TreatmentDate ||
                             ', Diagnosis: ' || treatment_record.Diagnosis);
    END LOOP;

    CLOSE treatments_cursor;
END ShowTreatmentsForDoctor;
/
SET SERVEROUTPUT ON;

EXEC ShowTreatmentsForDoctor(&id);

CREATE OR REPLACE PROCEDURE ShowAllSpecialties IS
    CURSOR specialty_cursor IS 
        SELECT SpecialtyID, SpecialtyName 
        FROM Specialty;

    specialty_record specialty_cursor%ROWTYPE;
BEGIN
    OPEN specialty_cursor;

    LOOP
        FETCH specialty_cursor INTO specialty_record;
        EXIT WHEN specialty_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Specialty ID: ' || specialty_record.SpecialtyID ||
                             ', Name: ' || specialty_record.SpecialtyName);
    END LOOP;

    CLOSE specialty_cursor;
END ShowAllSpecialties;
/
SET SERVEROUTPUT ON;
EXEC ShowAllSpecialties();

CREATE OR REPLACE PROCEDURE ShowPatientsWithDiagnosis(p_DiagnosisName IN VARCHAR2) IS
    CURSOR patients_cursor IS 
        SELECT p.PatientID, p.Name, p.EGN, t.TreatmentDate
        FROM Patient p
        JOIN Treatment t ON p.PatientID = t.PatientID
        WHERE t.Diagnosis = p_DiagnosisName;

    patient_record patients_cursor%ROWTYPE;
BEGIN
    OPEN patients_cursor;

    LOOP
        FETCH patients_cursor INTO patient_record;
        EXIT WHEN patients_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Patient ID: ' || patient_record.PatientID ||
                             ', Name: ' || patient_record.Name ||
                             ', EGN: ' || patient_record.EGN ||
                             ', Treatment Date: ' || patient_record.TreatmentDate);
    END LOOP;

    CLOSE patients_cursor;
END ShowPatientsWithDiagnosis;
/
SET SERVEROUTPUT ON;

EXEC ShowPatientsWithDiagnosis('&diagnosis_name');
/

CREATE OR REPLACE PROCEDURE ShowTreatmentsForPatient(p_PatientID IN Patient.PatientID%TYPE) IS
    CURSOR treatments_cursor IS 
        SELECT t.TreatmentID, t.DoctorID, d.Name AS DoctorName, t.TreatmentDate, t.Duration, t.Diagnosis
        FROM Treatment t
        JOIN Doctor d ON t.DoctorID = d.DoctorID
        WHERE t.PatientID = p_PatientID;

    treatment_record treatments_cursor%ROWTYPE;
BEGIN
    OPEN treatments_cursor;

    LOOP
        FETCH treatments_cursor INTO treatment_record;
        EXIT WHEN treatments_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Treatment ID: ' || treatment_record.TreatmentID ||
                             ', Doctor ID: ' || treatment_record.DoctorID ||
                             ', Doctor Name: ' || treatment_record.DoctorName ||
                             ', Treatment Date: ' || treatment_record.TreatmentDate ||
                             ', Duration: ' || treatment_record.Duration ||
                             ', Diagnosis: ' || treatment_record.Diagnosis);
    END LOOP;

    CLOSE treatments_cursor;
END ShowTreatmentsForPatient;
/
SET SERVEROUTPUT ON;

EXEC ShowTreatmentsForPatient(&patient_id);

CREATE SEQUENCE seq_SpecialtyID
    START WITH 1
    INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_SpecialtyID_AutoIncrement
BEFORE INSERT ON Specialty
FOR EACH ROW
BEGIN
    :NEW.SpecialtyID := seq_SpecialtyID.NEXTVAL;
END;
/
INSERT INTO Specialty (SpecialtyName) VALUES ('Dermatologggy');

---
CREATE SEQUENCE seq_DiagnosisID
    START WITH 1
    INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_DiagnosisID_AutoIncrement
BEFORE INSERT ON Diagnosis
FOR EACH ROW
BEGIN
    :NEW.DiagnosisID := seq_DiagnosisID.NEXTVAL;
END;
/
INSERT INTO Diagnosis (DiagnosisName) VALUES ('&name');

---
CREATE SEQUENCE seq_DoctorID
    START WITH 1
    INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_DoctorID_AutoIncrement
BEFORE INSERT ON Doctor
FOR EACH ROW
BEGIN
    :NEW.DoctorID := seq_DoctorID.NEXTVAL;
END;
/
INSERT INTO Doctor (SpecialtyID, Name, Phone) VALUES (2, 'Dr. Ivanova', '555-1234');

---

CREATE SEQUENCE seq_NewPatientID
    START WITH 1
    INCREMENT BY 1;


CREATE OR REPLACE TRIGGER trg_PatientID_AutoIncrement
BEFORE INSERT ON Patient
FOR EACH ROW
BEGIN
    :NEW.PatientID := seq_ExistingPatientID.NEXTVAL;
END;
/

INSERT INTO Patient (Name, EGN) VALUES ('&name', '&egn');

---

CREATE SEQUENCE seq_TreatmentID
    START WITH 1
    INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_TreatmentID_AutoIncrement
BEFORE INSERT ON Treatment
FOR EACH ROW
BEGIN
    :NEW.TreatmentID := seq_TreatmentID.NEXTVAL;
END;
/
INSERT INTO Treatment (PatientID, DoctorID, TreatmentDate, Duration, Diagnosis)
VALUES (2, 2, TO_DATE('2023-02-15', 'YYYY-MM-DD'), 5, 'Skin Tesst');

CREATE SEQUENCE seq_TreatmentID
    START WITH 1
    INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_TreatmentID_AutoIncrement
BEFORE INSERT ON Treatment
FOR EACH ROW
BEGIN
    IF :NEW.TreatmentID IS NULL THEN
        :NEW.TreatmentID := seq_TreatmentID.NEXTVAL;
    END IF;
END;
/



CREATE OR REPLACE TRIGGER trg_CheckPatientUnderTreatment
BEFORE INSERT ON Patient
FOR EACH ROW
DECLARE
    v_current_treatment_count INT;
BEGIN
    SELECT COUNT(*) 
    INTO v_current_treatment_count
    FROM Treatment
    WHERE PatientID = :NEW.PatientID;

    IF v_current_treatment_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '??????? ' || :NEW.PatientID || ' ???? ?? ?????? ? ?? ???? ?? ???? ??????? ??????.');
    END IF;
END;
/

--DELETE FROM Treatment WHERE PatientID = 1;


INSERT INTO Treatment (PatientID, DoctorID, TreatmentDate, Duration, Diagnosis)
VALUES (1, 1, TO_DATE('2023-08-01', 'YYYY-MM-DD'), 5, 'Test Diagnosis');


ALTER TRIGGER TRG_PATIENTID_AUTOINCREMENT ENABLE;

--??????? ?? ???????, ?? ????

SELECT t.PatientID, p.Name AS PatientName, t.TreatmentDate, t.Duration, t.Diagnosis
FROM Treatment t
JOIN Patient p ON t.PatientID = p.PatientID
WHERE p.EGN = '&egn'
ORDER BY t.TreatmentDate;

--				??????? ?? ?????, ?? ????????

SELECT t.PatientID, p.Name AS PatientName, t.TreatmentDate, t.Duration, t.Diagnosis, d.Name
FROM Treatment t
JOIN Doctor d ON t.DoctorID = d.DoctorID
JOIN Patient p ON t.PatientID = p.PatientID
WHERE d.Name = '&doctor_name' AND d.Phone = '&doctor_phone'
ORDER BY t.Diagnosis;

--?????? ??????? ?? ??????

SELECT t.TreatmentID, t.PatientID, p.Name AS PatientName, t.DoctorID, d.Name AS DoctorName, t.TreatmentDate, t.Duration, t.Diagnosis
FROM Treatment t
JOIN Patient p ON t.PatientID = p.PatientID
JOIN Doctor d ON t.DoctorID = d.DoctorID
WHERE t.TreatmentDate BETWEEN TO_DATE('&startdate', 'YY-MM-DD') AND TO_DATE('&enddate', 'YY-MM-DD')
ORDER BY t.TreatmentDate;

--??????? ?? ??????? 
SELECT p.PatientID, p.Name AS PatientName, p.Egn
FROM Patient p
WHERE p.EGN = '&egn';

--??????? ?? ?????

SELECT d.DoctorID, d.Name AS DoctorName, d.Phone, s.SpecialtyName
FROM Doctor d
JOIN Specialty s ON d.SpecialtyID = s.SpecialtyID
WHERE d.Name = '&doctor_name' AND d.Phone = '&doctor_phone';

--??????? ?? ????????
SELECT DiagnosisID, DiagnosisName
FROM Diagnosis
WHERE DiagnosisName = '&diagnosis_name';
    














