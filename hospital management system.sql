create database HospitalManagementSystem;
use HospitalManagementSystem;
# create table for patients
create table patients (
PatientID int primary key auto_increment,
firstname varchar(30),
lastname varchar(30),
dateofbirth date,
gender varchar(10),
phone varchar(15),
email varchar(50),
address text,
emergencycontact varchar(50),
bloodgroup varchar(5));

# create table for doctors
create table doctors(
DoctorID int primary key auto_increment,
firstname varchar(20),
lastname varchar(20),
specialty varchar(30),
phone varchar(15),
email varchar(30),
roomnumber varchar(10));

#create table for appointments
create table appointments (
appointmentid int primary key auto_increment,
patientid int,
doctorid int,
appointmentdate datetime,
reason varchar(200),
status varchar(50),
foreign key (patientid) references patients(patientid),
foreign key (doctorid) references doctors(doctorid));

#create table for medical records
create table medicalrecords (
recordid int primary key auto_increment,
patientid int,
doctorid int,
visitdate date,
diagnosis text,
treatment text,
prescription text,
notes text,
foreign key (patientid) references patients(patientid),
foreign key (doctorid) references doctors(doctorid));

#insert value for patients
INSERT INTO Patients (FirstName, LastName, DateOfBirth, Gender, Phone, Email, Address, EmergencyContact, BloodGroup) VALUES
('ravi', 'kumar', '1985-06-15', 'Male', '9876543210', 'ravi.doe@gmail.com', '123 Main St', 'john', 'A+'),
('senthil', 'raja', '1990-12-05', 'Female', '9876543211', 'senthil@yahoo.com', '456 gandhi St', 'selvi', 'B+'),
('shalman', 'Khan', '1978-08-20', 'Male', '9876543212', 'khan@gmail.com', '789 2nd St', 'Sara Khan', 'O+');
SELECT * FROM Patients;
 
#insert value for doctors
INSERT INTO Doctors (FirstName, LastName, Specialty, Phone, Email, RoomNumber) VALUES
('sharma', 'sun', 'Cardiology', '9123456780', 'sharma@hospital.com', '101'),
('Robert', 'Wilson', 'Orthopedics', '9123456781', 'robert.wilson@hospital.com', '102'),
('Sophia', 'Ragu', 'Pediatrics', '9123456782', 'sophia.ragu@hospital.com', '103');
 SELECT * FROM doctors;
 
 #insert value for appointments 
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Reason, Status) VALUES
(1, 1, '2025-05-15 09:00:00', 'Chest pain', 'Scheduled'),
(2, 2, '2025-05-16 11:30:00', 'Knee pain', 'Completed'),
(3, 3, '2025-05-17 10:00:00', 'Fever and cough', 'Scheduled'),
(1, 1, '2025-05-18 09:30:00', 'Follow-up', 'Scheduled');
SELECT * FROM appointments;

# insert value for medical records
INSERT INTO MedicalRecords (PatientID, DoctorID, VisitDate, Diagnosis, Treatment, Prescription, Notes) VALUES
(1, 1, '2025-04-20', 'Mild heart issue', 'Rest, monitoring', 'Aspirin', 'Needs echo test next visit'),
(2, 2, '2025-04-25', 'Ligament strain', 'Physiotherapy', 'Painkillers', 'Avoid pressure on knee'),
(3, 3, '2025-05-01', 'Viral fever', 'Rest and hydration', 'Paracetamol', 'Check if symptoms persist'),
(1, 1, '2025-05-01', 'Check-up', 'Continue monitoring', 'None', 'Stable');
SELECT * FROM medicalrecords;

#Get a list of all appointments with patient and doctor names.
SELECT 
    a.AppointmentID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    a.AppointmentDate,
    a.Status
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID;

#Create a view to show the latest medical record for each patient.
CREATE VIEW LatestMedicalRecords AS
SELECT 
    mr.RecordID,
    mr.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    mr.VisitDate,
    mr.Diagnosis,
    mr.Treatment,
    mr.Prescription
FROM MedicalRecords mr
JOIN Patients p ON mr.PatientID = p.PatientID
WHERE mr.VisitDate = (
    SELECT MAX(VisitDate) 
    FROM MedicalRecords 
    WHERE PatientID = mr.PatientID
);

SELECT * FROM LatestMedicalRecords;

#Find all doctors who have more than 5 appointments scheduled.
SELECT 
    d.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    (SELECT COUNT(*) 
     FROM Appointments a 
     WHERE a.DoctorID = d.DoctorID AND a.Status = 'Scheduled') AS ScheduledAppointments
FROM Doctors d
WHERE 
    (SELECT COUNT(*) 
     FROM Appointments a 
     WHERE a.DoctorID = d.DoctorID AND a.Status = 'Scheduled') > 1;


#Create a stored procedure to count total appointments per doctor.
DELIMITER //

CREATE PROCEDURE GetAppointmentCountPerDoctor()
BEGIN
    SELECT 
        d.DoctorID,
        CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
        COUNT(a.AppointmentID) AS TotalAppointments
    FROM Doctors d
    LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
    GROUP BY d.DoctorID;
END //

DELIMITER ;
CALL GetAppointmentCountPerDoctor();
