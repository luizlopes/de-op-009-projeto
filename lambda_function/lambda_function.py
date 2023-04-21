import psycopg2

def lambda_metodo(event, context):
    print(context)
    print(event)
    print("Sou uma função lambda que subi com o terraform! vamo simbora!");

    conn = psycopg2.connect(database="mydb",
                        host="banquinho.c1hyijajfphq.us-east-1.rds.amazonaws.com",
                        user="username",
                        password="password",
                        port="5432")
    
    cursor = conn.cursor()

    cursor.execute("SELECT version()")

    db_version = cursor.fetchone()
    print(db_version)

    # message = 'Sou uma função lambda que subi com o terraform! vamo simbora! Quem me chamou foi: {} {}!'.format(event['nome'], event['sobrenome'])
    # return {
    #     'message' : message
    # }
