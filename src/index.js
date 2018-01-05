'use strict';

const AWS = require('aws-sdk');
const S3 = new AWS.S3({
  signatureVersion: 'v4',
});
const Sharp = require('sharp');
const BUCKET = process.env.BUCKET;
const URL = process.env.URL;

exports.handler = function(event, context, callback) {
  const key = event.queryStringParameters.key;
  const match = key.match(/(\d+)x(\d+)\/(.*)/);

  const cleanWidth = function(width) {
    if(isNaN(width) || width > 1024){
      return 1024
    }
    return width
  }

  const cleanHeight = function(height) {
    if(isNaN(height) || height > 768){
      return 768
    }
    return height
  }

  const cleanFileExt = function(fileExt) {
    if(fileExt === 'jpg' || fileExt === 'jpeg'){
      return 'jpeg'
    }
    if(fileExt === 'webp'){
      return 'webp'
    }
    if(fileExt === 'png'){
      return 'png'
    }
    return 'jpeg'

  }

  const width = cleanWidth(parseInt(match[1], 10));
  const height = cleanHeight(parseInt(match[2], 10));

  const fileExt = cleanFileExt(match[3].split('.')[1]);
  const originalKey = match[3].split('.')[0]+ '.jpg';

  S3.getObject({Bucket: BUCKET, Key: originalKey}).promise()
    .then(data => {
      const img = Sharp(data.Body).resize(width, height);
      return img
      .toFormat(fileExt)
      .toBuffer();
    })
    .then(buffer => S3.putObject({
        Body: buffer,
        Bucket: BUCKET,
        ContentType: 'image/'+fileExt,
        Key: key,
      }).promise()
    )
    .then(() => callback(null, {
        statusCode: '301',
        headers: {'location': `${URL}/${key}`},
        body: '',
      })
    )
    .catch(err => callback(err))
}
