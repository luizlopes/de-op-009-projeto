import os
import psycopg2

def lambda_metodo(event, context):
    print(context)
    print(event)
    print("Sou uma função lambda que subi com o terraform! vamo simbora!");

    conn = psycopg2.connect(
        host=os.environ['DATABASE_HOST'],
        port=os.environ['DATABASE_PORT'],
        database=os.environ['DATABASE_NAME'],
        user=os.environ['DATABASE_USERNAME'],
        password=os.environ['DATABASE_PASSWORD']
    )
    
    cursor = conn.cursor()

    cursor.execute("SELECT version()")

    db_version = cursor.fetchone()
    print(db_version)

    # message = 'Sou uma função lambda que subi com o terraform! vamo simbora! Quem me chamou foi: {} {}!'.format(event['nome'], event['sobrenome'])
    # return {
    #     'message' : message
    # }
