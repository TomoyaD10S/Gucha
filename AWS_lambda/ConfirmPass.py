import json
import boto3
import random
import time

def lambda_handler(event, context):

    queryStringParameters = event.get('queryStringParameters', {})
    passme = queryStringParameters.get('PassMe', '')
    passmatch = queryStringParameters.get('PassMatch', '')

    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('ConfirmPass')
    
    
    response = table.put_item(
        Item={
            'PassMe': passmatch,
            'PassMatch': passme
        }
    )
    
    
    for _ in range(15):
        time.sleep(1)
        
        response = table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('PassMe').eq(passme)
        )
        
        match = response['Items']
        if not match:
            continue
        match = response['Items'][0]
        
        if match['PassMatch'] == passmatch:
            table.delete_item(
                Key={
                    'PassMe': passme
                }
            )
            return {
                'statusCode': 200,
                'body': json.dumps("yes")
                }
        
    
    table.delete_item(
        Key={
            'PassMe': passmatch
        }
    )
    
    
    return {
        'statusCode': 200,
        'body': json.dumps('no')
    }
