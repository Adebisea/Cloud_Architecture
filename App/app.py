from flask import Flask, request, render_template_string
import psycopg2
import boto3
from botocore.exceptions import ClientError
import json

app = Flask(__name__)

# Fetch DB credentials
def get_db_creds():
    ssm_client = boto3.client('ssm')
    db_creds = ssm_client.get_parameters(
            Names=["/db/secret_name", "/db/host", "/db/username" ], WithDecryption=True
        )
    return db_creds

db_creds = get_db_creds()
secret_arn = db_creds['Parameters'][0].Value
db_host     = db_creds['Parameters'][1].Value
db_username = db_creds['Parameters'][2].Value
region_name = "us-west-1"

# get db passwd secret value
def get_secret():
    
    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_arn
        )
    except ClientError as e:
        raise e

    secret = get_secret_value_response['SecretString']
    return secret

def create_conn():
    secret = get_secret()
    conn = psycopg2.connect(
        dbname= "db_techn",
        user= db_username,
        password= secret,
        host= db_host,
        port=5432
    )
    return conn

conn = create_conn()
cur = conn.cursor()
def create_table_users():
    cur.execute("CREATE TABLE IF NOT EXISTS users (name TEXT)")
    conn.commit()

form_html = '''
<form method="POST" action="/submit">
  <label>Hello, welcome! What's your name?</label><br>
  <input name="name" required>
  <button type="submit">Submit</button>
</form>
'''

@app.route("/", methods=["GET"])
def home():
    return render_template_string(form_html)

@app.route("/submit", methods=["POST"])
def submit():
    name = request.form["name"]
    cur.execute("INSERT INTO users (name) VALUES (%s)", (name,))
    conn.commit()
    return f"Glad to meet you, {name}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
