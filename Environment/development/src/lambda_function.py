def lambda_handler(event, context):
    
    body = '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Homepage</title>
    </head>
    <body>
        <h1>Redneck Renovations</h1>
        <p>Welcome to Redneck Renovations</p>
    </body>
    </html>'''
    
    response = {
        'statusCode': 200,
        'headers': {"Content-Type": "text/html",},
        'body': body
    }
    
    return response