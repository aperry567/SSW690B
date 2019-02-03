# Use Cases for Doctors OnDemand App

Use Case 1 | Information
--- | ---
**UC001** | Patient Signup
**Actors** | Patient					
**Flow** | Patient comes to app, enters email and a password, agrees to rules, and fills in patient profile					

Use Case 2 | Information
--- | ---
**UC002**	| Get a Doctor					
**Actors** | Patient					
**Flow** | Patient decides they need to talk to a doctor, clicks button, fill out a questionnaire on their problem, system matches their problem up to potential doctors based on the area of the problem and the doctor is currently available for a chat					

Use Case 3 | Information
--- | ---
**UC003** | Chat with Doctor					
**Actors** | Doctor, Patient					
**Flow** | A direct communication channel is created between the doctor and patient after patient accepts cost of call					
**Alt Flow** | No doctor is currently available that matches your criteria.  Please try again later message given to the patient					
**Alt Flow 2** | Patient is not happy with the cost of the call and cancels the chat					

Use Case 4 | Information
--- | ---
**UC004** | Patient Scheduled tests/appointments Lists					
**Actors** | Patient					
**Flow** | Patient is able to go into the app and see the list of appointments and tests the doctors have created for them including date/time, location, and reason for visit					
Use Case 5 | Information
--- | ---
**UC005** | Patient profile update					
**Actors** | Patient					
**Flow** | Patient is able to update their full name, address, phone.  Health Questionnaire, Credit Card Info					

Use Case 6 | Information
--- | ---
**UC006** | Login					
**Actors** | Patient, Doctor, Sys Admin					
**Flow** | User attempts to login with their email and password and then go to their home screen					
**Alt Flow** | User is unable to login and clicks the reset password button and recieves and email to reset their password					

Use Case 7 | Information
--- | ---
**UC007** | Patient Care History					
**Actors** | Patient					
**Flow** | Details of the patients general medical/mental history					

Use Case 8 | Information
--- | ---
**UC008** | Patient Doctor History					
**Actors** | Patient					
**Flow** | Doctors notes on their patient					

Use Case 9 | Information
--- | ---
**UC009** | Doctor Signup					
**Actors** | Doctor 					
**Flow** | Doctor completes the sign up process and fills in their profile					

Use Case 10 | Information
--- | ---
**UC010** | Doctor profile update					
**Actors** | Doctor					
**Flow** | Doctor completes her/his medical credentials and licensing criteria and waits for approval from Doctors OnDemand board.  Inserts how much the visit will cost per call				
Use Case 11 | Information
--- | ---
**UC011** | Doctor patient list					
**Actors** | Doctor					
**Flow** | Doctors list of all patients under their care past and present					

Use Case 12 | Information
--- | ---
**UC012** | Doctor patient details					
**Actors** | Doctor					
**Flow** | Doctors notes on the individual patient(s) and patient profile					

Use Case 13 | Information
--- | ---
**UC013** | Doctor patient treatment list					
**Actors** | Doctor					
**Flow** | Doctor will be able to see the given treatment by the date					

Use Case 14 | Information
--- | ---
**UC014** | Doctor patient create apointments/tests					
**Actors** | Doctor					
**Flow** | Doctor can schedule a follow-up appoint whether in person or via live chat					

Use Case 15 | Information
--- | ---
**UC015** | Doctor file perscriptions					
**Actors** | Doctor					
**Flow** | Doctor creates a perscription request in the app and files it via ez-scripts					

Use Case 16 | Information
--- | ---
**UC016** | System Admin user management					
**Actors** | System Admin					
**Flow** | System admin is able to view all users and see basic info about (name, address, phone) and change email for users who have a new email address and need it updated				

Use Case 17 | Information
--- | ---
**UC017** | System Admin Activate Doctors					
**Actors** | System Admin					
**Flow** | The SA once the Doctors OnDemand board approves grants the doctor(s) access to the app 					

Use Case 18 | Information
--- | ---
**UC018** | User audit logs					
**Actors** | System Admin, Doctor, Patient					
**Flow** | Able to see the audits of actions performed by the user.  The actions will be recorded by date/time, the category of action (appointment, perscription, etc) and user involved if applicable					

Use Case 19 | Information
--- | ---
**UC019** | Usage/Income Reports					
**Actors** | System Admin					
**Flow** | Shows details about number of users signed up, (doctors vs patients), number of chats/perscriptions filled per day/week/month, total doctors online now, revenue per day/week/month					
Use Case 20 | Information
--- | ---
**UC020** | User Billing History					
**Actors** | Patient, Doctor					
**Flow** | User list of charges for doctor chats					

Use Case 21 | Information
--- | ---
**UC021** | Doctor patient billing history					
**Actors** | Doctor					
**Flow** | List of charges from the current doctor for the patient (cannot see other doctor's charges)					
