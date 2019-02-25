# Use Cases for Doctors OnDemand App

ID | UC001
--- | ---
**Title** | Patient Signup
**Actors** | Patient					
**Flow** | Patient comes to app, enters email and a password, agrees to rules, and fills in patient profile					

ID | UC002
--- | ---
**Title**	| Get a Doctor					
**Actors** | Patient					
**Flow** | Patient decides they need to talk to a doctor, clicks button, fill out a questionnaire on their problem, system matches their problem up to potential doctors based on the area of the problem and the doctor is currently available for a chat					

ID | UC003
--- | ---
**Title** | Chat with Doctor					
**Actors** | Doctor, Patient					
**Flow** | A direct communication channel is created between the doctor and patient after patient accepts cost of call					
**Alt Flow** | No doctor is currently available that matches your criteria.  Please try again later message given to the patient					
**Alt Flow 2** | Patient is not happy with the cost of the call and cancels the chat					

ID | UC004
--- | ---
**UC004** | Patient Scheduled tests/appointments Lists					
**Actors** | Patient					
**Flow** | Patient is able to go into the app and see the list of appointments and tests the doctors have created for them including date/time, location, and reason for visit					

ID | UC005
--- | ---
**UC005** | Patient profile update					
**Actors** | Patient					
**Flow** | Patient is able to update their full name, address, phone.  Health Questionnaire, Credit Card Info					

ID | UC006
--- | ---
**Title** | Login					
**Actors** | Patient, Doctor, Sys Admin					
**Flow** | User attempts to login with their email and password and then go to their home screen					
**Alt Flow** | User is unable to login and clicks the reset password button and recieves and email to reset their password					

ID | UC007
--- | ---
**Title** | Patient Care History					
**Actors** | Patient					
**Flow** | Details of the patients general medical/mental history					

ID | UC008
--- | ---
**Title** | Patient Doctor History					
**Actors** | Patient					
**Flow** | Doctors notes on their patient					

ID | UC009
--- | ---
**Title** | Doctor Signup					
**Actors** | Doctor 					
**Flow** | Doctor completes the sign up process and fills in their profile					

ID | UC010
--- | ---
**UC010** | Doctor profile update					
**Actors** | Doctor					
**Flow** | Doctor completes her/his medical credentials and licensing criteria and waits for approval from Doctors OnDemand board.  Inserts how much the visit will cost per call				

ID | UC011
--- | ---
**Title** | Doctor patient list					
**Actors** | Doctor					
**Flow** | Doctors list of all patients under their care past and present					

ID | UC012
--- | ---
**Title** | Doctor patient details					
**Actors** | Doctor					
**Flow** | Doctors notes on the individual patient(s) and patient profile					

ID | UC013
--- | ---
**Title** | Doctor patient treatment list					
**Actors** | Doctor					
**Flow** | Doctor will be able to see the given treatment by the date					

ID | UC014
--- | ---
**Title** | Doctor patient create apointments/tests					
**Actors** | Doctor					
**Flow** | Doctor can schedule a follow-up appoint whether in person or via live chat					

ID | UC015
--- | ---
**UC015** | Doctor file perscriptions					
**Actors** | Doctor					
**Flow** | Doctor creates a perscription request in the app and files it via ez-scripts					

ID | UC016
--- | ---
**UC016** | System Admin user management					
**Actors** | System Admin					
**Flow** | System admin is able to view all users and see basic info about (name, address, phone) and change email for users who have a new email address and need it updated				

ID | UC017
--- | ---
**Title** | System Admin Activate Doctors					
**Actors** | System Admin					
**Flow** | The SA once the Doctors OnDemand board approves grants the doctor(s) access to the app 					

ID | UC018
--- | ---
**Title** | User audit logs					
**Actors** | System Admin, Doctor, Patient					
**Flow** | Able to see the audits of actions performed by the user.  The actions will be recorded by date/time, the category of action (appointment, perscription, etc) and user involved if applicable					

ID | UC019
--- | ---
**Title** | Usage/Income Reports					
**Actors** | System Admin					
**Flow** | Shows details about number of users signed up, (doctors vs patients), number of chats/perscriptions filled per day/week/month, total doctors online now, revenue per day/week/month					

ID | UC020
--- | ---
**Title** | User Billing History					
**Actors** | Patient, Doctor					
**Flow** | User list of charges for doctor chats					

ID | UC021
--- | ---
**Title** | Doctor patient billing history					
**Actors** | Doctor					
**Flow** | List of charges from the current doctor for the patient (cannot see other doctor's charges)					
