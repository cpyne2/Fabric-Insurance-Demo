
![agent](https://github.com/user-attachments/assets/aea60bd1-282c-48e1-b32a-1af2b8d048aa)
# Fabric-Insurance-Demo
This solution builds a demo environment showing how Fabric Data Agents can reason over a simulated insurance dataset

![Question1](https://github.com/user-attachments/assets/5daa08fc-76f0-4105-ac4d-ab905203765a)


# Requrements
1. A Fabric enabled workspace

# SQL Database and Table setup
1. From the workspace, click New Item > SQl Database > name ClaimsDB
2. Click New Query and copy/past the contents of **1 - sql tables.sql** and run.  3 tables and 1 view should be created

# Semantic Model Setup
1. Get your workspace Connection Link.   Workspace > Workspace Settings > Workspace type > Connection Link.  My workspace is named "Insurance Demo" so my link is powerbi://api.powerbi.com/v1.0/myorg/Insurance%20Demo
2. Install Tabular Editor 3
3. Unzip **2 - Sematic Model.zip**
4. Tabular Editor - File > Open from Model Folder.  Select **2 - Sematic Model** folder. Select no to workspace database question
5. Edit the datasouce connection.  In TOM explorer, navigate to Model > Expressions > "DirectLake - ClaimsDB"
    a. The two GUIDs in this link need to be edited to reference your workspace and the SQL database you just created.

   		https://onelake.dfs.fabric.microsoft.com/**(put your workspace GUI here)**/**(Put your SQL DB guid here)**

   You can find your workspace guid right in the power bi portal.  Click on your workspace and you'll see its GUID in the browser URL.   To get your SQL Database guid, click on settings next to your SQL database and go to connect strings.  Your SQL Guid will be something like "ClaimsDB-**0f8ce05d-71d1-451e-8d50-6538baecc356**".  Remove ClaimsDB- and just take the guid
7. From Tabular Explorder, select Model > Deploy > SERVER = your workspace conneciton link, Select your Auth option, Microosft Entra MFA
8. New Database Name - **ClaimsModel**
9. ClaimsModel should now be deployed to your workspace.  Run a manual refresh to sync it with the SQL database.

# PowerBI Report Creation - Create a starter report based on the semantic model. 
1. Click ClaimsModel > Open
2. File > Create New Report
3. Click Copilot and enter these prompts to have some quick tabs created. (
  a. "create a new page - Claims Dashboard Summary"
  b. "create for me a Customer Information and Metrics page"
  c. "Create a Policy Dashboard"
  d. "Create a Claim Details page"
4. Click Save and and save this report as Insurance Dashboard

# Lakehouse Setup - Create table and load adjuster notes
1. Create a lakehouse named **ClaimsLake**
2. From the workspace - Import >  Notebook > From this Computer > Upload > **3 - ClaimsAdjusterNotes_Notebook.ipynb**
3. Click on the notebook > add data items > From OneLake Catalog > (your lakehouse), ie - **ClaimsLake**
4. Click Run All

# Prep the Semantic Model Data for AI.  
**note - This step has already been completed in the model we uploaded.  It is a best practice to Prep Data for AI whenever creating a data agent.**
1. Click on ClaimsModel semantic model and select Prep Data for AI.  If prompted, select OK to convert to large semantic model storage format.
2. Review "Simplify the Data Schema".   You'll see that some fields we dont want AI to evaluate have been turned off.  Turning off unwanted fields will improve performance.
3. Verified Anserws - (not currently set in this model)
4. Add AI Instuctions - (not currently set in this model)
   
# Data Agent Setup and Prep
**Create a Data Agent that can reason over this data.  Questions will primarily go against the semantic model, but can push down to the lakehouse to look at adjuster notes when needed.  The agent will be trained with Agent Instuctions, Data Source Instuctions, and Example SQL queries**
1. Worspace > New Item > Data Agent
2. Name the agent **Claims Agent**
3. Click Add Data > Datasouce.  Select the **ClaimsModel** and then repeat to add the **ClaimsLake**.
4. Expand the sematic model and the lakehouse and check off all 4 tables
5. Click Agent Instuctions and past in the contents of **4 - Agent Instuctions.txt**.  Be sure to delete starter instructions first.
6. Click on Setup > ClaimsLake > Data Souce Instuctions.  Paste in contents of **5 - Data Souce Instuctions.txt** being sure to clear any starter instructions before pasting.
7. Click on Example Queries > Add Example.  Open **6 - Example queries.txt** and past in each example question and SQL example. Click Add after each query is entered so each one can go in a new box.  Ensure all queries succcessfully validate.
Click Publish and enter the Data Agent Purpose and Capabilities from **7 - Agent Purpose.txt**

![flow](https://github.com/user-attachments/assets/af659342-c1dd-4eb9-8791-a92609394c4e)

# Ask the Data Agent some questions
**Claims Data Agent — Demo Question Script**

🟢 Level 1 — Semantic Model Basics
Simple headline numbers to prove the agent understands the data.

	1. "How many insurance claims do we have on record?"
	2. "What is the total amount claimed across all policies?"
	3. "How many claims are currently approved, denied, or still under review?"
	4. "What is our most common claim type?"
	5. "Break down the total number of claims by policy type."

🟡 Level 2 — Semantic Model Intermediate
Business-relevant questions that start to tell a story.

	6. "What is our current claim approval rate?"
	7. "How much money has been approved versus how much was originally claimed?"
	8. "Which state has the highest number of claims?"
	9. "Who is our most active claims adjuster and how many claims have they handled?"
	10. "How many claims are still pending and what is the total dollar amount at risk from those open claims?"

🔴 Level 3 — Semantic Model Advanced
More advanced business questions. These questions surface core business problems.

	11. "How many claims were filed outside the policy coverage window?"
	12. "What is the total dollar exposure from claims that were filed outside the policy window?"
	13. "What percentage of our total claims volume were filed outside the policy coverage window?"
	14. "How much money did we save by denying invalid claims rather than paying them out?"
	15. "Which active policies are expiring in the next 90 days and do any of them have claims that are still open?"

🔵 Level 4 — Cross Source: Semantic Model + Lakehouse
Complex questions too complex to be answerrd in a PowerBI Report. These pull structured claim data from the semantic model and narrative investigation history from the Lakehouse adjuster notes table.

	16. "Show me every claim that was filed outside the policy coverage window, including the customer name, how many days out of window it was filed, the claim amount, and all adjuster notes on record for each of those claims."
	17. "Find any claims that are currently in review or submitted status, then pull the most recent adjuster note for each one so we can see where the investigation stands."
