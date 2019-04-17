Create a fullstack single page application using the serverless framework! This project was bootstrapped with [Create React App](https://github.com/facebookincubator/create-react-app) and [CRAFT](https://github.com/stoyan/craft).

## Tweaks I made to the fork

- Initialized a serverless framework project for easy backend services.
- Added a `services` directory to deliniate the react application from the serverless functions.
- Added `styled-components` to the `package.json`, because I never want to be without it again.
- Added a the directory `src/utils` to keep API and global style vars for the design library.
- Automated the entire CI/CD pipeline with Terraform.
- Used [prompts.js](https://github.com/terkelg/prompts)  for easy setup and configuration. Just follow the CLI to get Terraform all set up!

**BEWARE** -- THIS WILL COST YOU MONEY. IT WILL SPIN UP THE FOLLOWING AWS RESOURCES:

- CodePipeline pipeline
- CodeBuild project
- CloudFront distribution
- s3 buckets for pipeline and web hosting
- Lambda for deployment + whatever extra lambdas you define in `serverless.yml` for your backend.
- DNS records
- SSL certificate

## Prerequisites
- You must already have an AWS account. Ideally, you have a user specific to Terraform so you can manage permissions for a specific set of provisioning keys.
- A domain registered with Route53 or pointing at a registered Route53 domain. One of the configuration inputs is the hosted zone id. You'll need to paste this into the prompt for the CloudFormation distribution to work.
- Terraform
- Node.js version with async/await

## Getting Started
```
npm install -g serverless
npm install -g craftool
craft {{ AppName }} https://github.com/steph-query/craft-serverless-template/archive/master.zip
```

You'll need to `cd` in and initialize your git repo before running 
```
npm install
./setup.sh
```

This step will take you through the `Prompts.js` CLI. Give some thought to how you want your cloud assets named. It will set these values in your environment for Terraform to orchestrate your provisioning. If you decide you don't want all the cloud resources, you can hack the terraform files as needed. PR's welcome!

From there you can just start working on your react app and update `package.json` as needed.

## Deployment

Deploying your backend services is as simple as running `sls deploy`. All the Lambda and API Gateway management is handled by Serverless, which uses CloudFormation under the hood.

The project extends the standard `serverless.yml` with a couple of Terraform configurations to set up AWS CodeBuild, CodePipeline, and CloudFront. The result is a github webhook that triggers a CodePipeline to pull and build your code, with a final step that uses a Lambda to push the artifact to the publicly hosted s3 bucket, upon which the CloudFront distribution sits behind the Route53 DNS. Because the deploy Lambda is defined in the serverless configuration, you need to run `sls deploy` first, or Terraform won't be able to find the lambda function, aka the last step in the deployment pipeline.

Please be advised, this can take a **long** time to set up, as we're setting up SSL for the project and must validate the certs after they are issued by AWS. This is not fast, potentially 30-45 minutes. No, it's not broken. You only have to do it once, so just be patient.

*The good*:
- You get CI for your SPA without having to deal with GUI bullcrap that comes with setting up all these goddam AWS services! Hooray!
- You get a single deployment process for all the services you set up outside of your SPA! Hip hip, hooray!

*The bad*:
- You are locked into AWS... for now. (golden handcuffs!)

## Extending the serverless setup:
- If you add a new serverless plugin to your setup, make sure to add it to `package.json`. That way it will automatically be included in AWS CodeBuild process, and you will not have to keep updating `buildpsec.yml`.
- You can any cloud resources, such as a DynamoDB table for your backend in the `Resources` section of the `serverless.yml` file. You shouldn't need to mess with the Terraform stuff unless you really want to mess with the deployment process. YMMV.

## The frontend:

### A bit about styles
With `styled-components`, you never really need to use stylesheets again. You can also get the benefits of SASS and CSS variables by storing them in an object, where they can be globally updated. This object lives in `src/utils/styles/index.js`, and makes for incredibly easy theme changes.

Consider the following example:
```javascript
// styles/index.js:
export const theme = {
  blue: 'rgb(29,31,177)',
  blue2: 'rgb(162,217,218)'
}
```
Wrapping your entire app in the `<ThemeProvider theme={theme}> ...children...  </ThemeProvider>` gives you access to your theme values inside any of its descendant components.

```javascript
// src/components/someComponent.js
import styled from 'styled-components';

const StyledDiv = styled.div`
  color: ${props.theme.blue};
  background-color: ${props.theme.blue2};
`;

// Your compenent renders StyledDiv in its render method
```

---
## TODO:
- Update the Prompts config to be more dynamic and alter the terraform setup as needed.
- Figure out the optimal way to automate backend deployment. Find a way to include this step in `buildspec.yml` that doesn't lose the serverless state information in the ephemeral build environment. Probably easy enough to push the metadata to s3 and configure all local environments to point there for the production setup (similar to TFState).

## General Resources

Please read official Create React App guide and don't try to customize configs because I am sure that all your requirements are reachable in 100% without config customizing or ejecting.

<img src="http://i.imgur.com/ULoeOL4.png" height="16"/> [Why I love Create React App and don't want to eject](https://medium.com/@valeriy.sorokobatko/why-i-love-create-react-app-e63b1be689a3)

* [Create React App GitHub](https://github.com/facebookincubator/create-react-app)
* [User Guide](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md)
* [Awesome Create React App](https://github.com/tuchk4/awesome-create-react-app)
* [Redux](http://redux.js.org/)
* [React Router](https://reacttraining.com/react-router/)
* [Reselect](https://github.com/reactjs/reselect)

### Redux

* [Redux Logger](https://github.com/evgenyrodionov/redux-logger)
* [Redux Thunk](https://github.com/gaearon/redux-thunk)
* compose with [Redux Chrome extension](https://github.com/zalmoxisus/redux-devtools-extension) for development env.

> [Displaying Map in state #124](https://github.com/zalmoxisus/redux-devtools-extension/issues/124)

>  Import [`set.prototype.tojson`](https://www.npmjs.com/package/set.prototype.tojson) and [`map.prototype.tojson`](https://www.npmjs.com/package/map.prototype.tojson) for correct view of [`Map`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map) and [`Set`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set) structures at Redux Chrome extension.

### `npm start`

Runs the app in development mode.<br>
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.<br>
You will see the build errors and lint warnings in the console.

<img src='https://camo.githubusercontent.com/41678b3254cf583d3186c365528553c7ada53c6e/687474703a2f2f692e696d6775722e636f6d2f466e4c566677362e706e67' width='600' alt='Build errors'>

### `npm test`

Runs the test watcher in an interactive mode.<br>
By default, runs tests related to files changes since the last commit.

[Read more about testing.](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md#running-tests)

### `npm run build`

Builds the app for production to the `build` folder.<br>
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.<br>
Your app is ready to be deployed!


---

## Troubleshooting

### `scripts/*-env.js`

We need this script because we can not run this

```
{
  "scripts": {
    "test": "node -r dotenv/config ./node_modules/.bin/react-scripts test dotenv_config_path=development.env",
  }
}
```

Because `jest` will accept `dotenv_config_path=development.env` as [regex for test files](https://facebook.github.io/jest/docs/cli.html#jest-regexfortestfiles).
