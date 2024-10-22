import pyodbc
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import streamlit as st

# Function to load SQL query from a .sql file
def load_sql_query(file_path):
    with open(file_path, 'r') as file:
        query = file.read()
    return query

# Function to fetch data from SQL Server
def fetch_data_from_sql(query):
    conn_str = (
        "Driver={ODBC Driver 17 for SQL Server};"  # Ensure you have the correct driver installed
        "Server=OPCSERVER1\\SQLEXPRESS;"  # Your server and instance name
        "Database=MachineMetrics;"  # Your database
        "UID=EdwardSeymourOPC;"  # Your username
        "PWD=ACSOPCSQL2024!@#;"  # Your password
    )
    
    # Establish connection to SQL Server
    conn = pyodbc.connect(conn_str)
    
    # Fetch data using the SQL query
    data = pd.read_sql(query, conn)
    
    # Close the connection
    conn.close()
    return data

# Load query from CombineAllSteps.sql
query = load_sql_query('CombineAllSteps.sql')

# Fetch data using the query
df = fetch_data_from_sql(query)

# Display the first few rows of the dataframe
# print(df.head())

import seaborn as sns
import matplotlib.pyplot as plt

# Function to create a histogram with distribution curve
def create_histogram(df):
    # Create figure and axes objects explicitly
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Create the histogram with bins of size 1 and KDE curve
    sns.histplot(df['GrossCycleTimeMin'], bins=range(int(df['GrossCycleTimeMin'].min()), int(df['GrossCycleTimeMin'].max()) + 1), kde=True, ax=ax)
    
    # Customize plot labels and title
    ax.set_title('GrossCycleTimeMin Distribution', fontsize=16)
    ax.set_xlabel('GrossCycleTimeMin', fontsize=12)
    ax.set_ylabel('Frequency', fontsize=12)
    
    return fig

# Streamlit app
st.title('CNC Data Dashboard')

# Display the data
st.write("CNC Data Preview")
st.dataframe(df.head())  # Display first 5 rows of data

# Seaborn plot
st.write("SQL Data Visualization")
fig = create_histogram(df)
st.pyplot(fig,bbox_inches='tight')

