import json
import boto3
import random
import time
import secrets
import string

def lambda_handler(event, context):
    
    def generate_password(length=20):
        alphabet = string.ascii_letters + string.digits
        password = ''.join(secrets.choice(alphabet) for i in range(length))
        return password
    
    
    queryStringParameters = event.get('queryStringParameters', {})
    id = queryStringParameters.get('id', '')
    language = queryStringParameters.get('language', '')

    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('ID_name')
    
    table_sub = dynamodb.Table('Match_'+language)
    table_sub.delete_item(
        Key={
            'Match': id
        }
    )
    
    response = table.put_item(
        Item={
            'ID': id,
            'Language': language
        }
    )
    
    response = table.scan(
        FilterExpression=boto3.dynamodb.conditions.Attr('Language').eq(language)
    )
    items = response['Items']
    n = len(items) // 2 * 2
    
    random.shuffle(items)
    pairs = [items[i:i + 2] for i in range(0, n, 2)]
    
    match_table_name = f'Match_{language}'
    match_table = dynamodb.Table(match_table_name)
    for pair in pairs:
        pass1 = generate_password()
        pass2 = generate_password()
        response = match_table.put_item(
            Item={
                'Match': pair[0]['ID'],
                'Match_op': pair[1]['ID'],
                'PassMe': pass1,
                'PassMatch': pass2
            }
        )
        response = match_table.put_item(
            Item={
                'Match': pair[1]['ID'],
                'Match_op': pair[0]['ID'],
                'PassMe': pass2,
                'PassMatch': pass1
            }
        )

    for pair in pairs:
        table.delete_item(
            Key={
                'ID': pair[0]['ID']
            }
        )
        table.delete_item(
            Key={
                'ID': pair[1]['ID']
            }
        )
    
    for _ in range(5):
        time.sleep(1)
        
        response = match_table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('Match').eq(id)
        )
        
        match = response['Items']
        if not match:
            continue
        match = response['Items'][0]
        
        if match['Match'] == id:
            match_table.delete_item(
                Key={
                    'Match': match['Match']
                }
            )
            return {
                'statusCode': 200,
                'body': {
                    'ID': json.dumps(match['Match_op']),
                    'PassMe': json.dumps(match['PassMe']),
                    'PassMatch': json.dumps(match['PassMatch'])
                    }
                }
    
    table.delete_item(
        Key={
            'ID': id
        }
    )
    
    
    return {
        'statusCode': 200,
        'body': json.dumps('')
    }
