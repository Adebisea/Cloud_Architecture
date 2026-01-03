from flask import Flask, request, render_template
import psycopg2
import boto3
from botocore.exceptions import ClientError
import json

app = Flask(__name__, static_url_path='/static', template_folder='static')
region_name = "eu-west-1"
# Fetch DB credentials
def get_db_creds():
    ssm_client = boto3.client('ssm', region_name=region_name)
    db_creds = ssm_client.get_parameters(
            Names=["/db/secret_name", "/db/host" ], WithDecryption=True
        )
    return db_creds

db_creds = get_db_creds()
db_creds = {creds['Name']:creds['Value'] for creds in db_creds['Parameters']}
secret_arn = db_creds["/db/secret_name"]
db_host     = db_creds["/db/host"]


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
    secret = json.loads(secret)
    conn = psycopg2.connect(
        dbname= "db_techn",
        user= secret['username'],
        password= secret['password'],
        host= db_host,
        port=5432
    )
    return conn

conn = create_conn()
cur = conn.cursor()
def create_table_users():
    cur.execute("CREATE TABLE IF NOT EXISTS users (name TEXT)")
    conn.commit()

create_table_users()

# Rendering the homepage 
@app.route("/", methods=["GET"])
def home():
    return render_template('index.html')

@app.route("/submit", methods=["POST"])
def submit():
    name = request.form["name"]
    cur.execute("INSERT INTO users (name) VALUES (%s)", (name,))
    conn.commit()
    return render_template('result.html', name=name)

if __name__ == "__main__":
    app.run(host="0.0.0.0",debug=False, port=5000)
