const fs = require('fs');
const prompts = require('prompts');

(async function () {
  const questions = [
    {
        type: 'text',
        name: 'dns',
        message: 'What is your website URL?'
    },
    {
      type: 'text',
      name: 'github_token',
      message: 'What is your github auth token?'
    },
    {
      type: 'text',
      name: 'lambda_function',
      message: 'What is the name of your lambda function?'
    }
  ];


  const answers = await prompts.prompt(questions);
  console.log(answers);
  const content = JSON.stringify(answers);
  console.log(content);
  fs.writeFile("./config.json", content, 'utf8', function (err) {
    if (err) {
        return console.log(err);
    }

    console.log("The file was saved!");
});

})();
