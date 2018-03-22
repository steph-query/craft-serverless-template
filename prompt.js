const fs = require('fs');
const prompts = require('prompts');

(async function () {
  const questions = [
    {
      name: 'project_name',
      type: 'text',
      message: 'What is the name of your project?'
    },
    {
      name: 'github_username',
      type: 'text',
      message: 'What is your Github username?'
    },
    {
      type: 'text',
      name: 'github_token',
      message: 'What is your github auth token?'
    },
    {
      name: 'github_repo',
      type: 'text',
      message: 'What is the name of the Github repository?'
    },
    {
      name: 'choose_codebuild_image',
      type: 'confirm',
      message: 'Do you want to choose the image for your codebuild environment?'
    },
    {
      name: 'codebuild_image',
      type: prev => prev ? 'text' : null,
      message: 'Which image would you like to use?',
      initial: 'aws/codebuild/nodejs:6.3.1'
    },
    {
      name: 'site_bucket_name',
      type: 'text',
      message: 'What do you want to call the s3 bucket that will host your site?'
    },
    {
      name: 's3_pipeline_bucket',
      type: 'text',
      message: 'Provide a name for the s3 bucket where your pipeline will store artifacts.'
    },
    {
      type: 'list',
      name: 'route53_domain_name',
      message: 'What URLs do you want to register with route53 to assign to your site?'
    },

    {
      name: 'route53_domain_zoneid',
      type: 'text',
      message: 'What hosted zone will you be registering these records?'
    }
  ];


  const answers = await prompts.prompt(questions);
  let output = '';
  Object.keys(answers).forEach(key => output += `export TF_VAR_${key}="${answers[key]}"` + '\n');


  console.log(output);
  fs.writeFile('.env', output, 'utf8', function (err) {
    if (err) {
        return console.log(err);
    }

    console.log('Terraform variables written to .env file!');
});

})();
