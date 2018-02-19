Create a fullstack single page application using the serverless framework! This project was bootstrapped with [Create React App](https://github.com/facebookincubator/create-react-app) and [CRAFT](https://github.com/stoyan/craft).

## Tweaks I made to the fork:

- Initialized a serverless framework project.
- Added a `services` directory to deliniate the react application from the serverless services.
- Added `styled-components` to the `package.json`, because I never want to be without it again.
- Added a the directory `src/utils` to keep API and global style vars for the design library.

## Deployment

The project extends the standard `sls.yml` with a couple of CloudFormation templates to set up AWS CodeBuild and AWS CodePipeline.

*The good*:
- You get CI for your SPA without having to deal with GUI bullcrap that comes with setting up all these goddam AWS services! Hooray!
- You get a single deployment process for all the services you set up outside of your SPA! Hip hip, hooray!

*The bad*:
- You are locked into AWS... for now. (golden handcuffs!)

## Extending the serverless setup:

- You can add more YAML files and reference in the same way we reference CodeBuild and CodePipeline configs in their respective files.
- If you add a new serverless plugin to your setup, make sure to add it to `package.json`. That way it will automatically be included in AWS CodeBuild process, and you will not have to keep updating `buildpsec.yml`.


## The frontend:


### A bit about styles

With `styled-components`, you never really need to use stylesheets again. You can also get the benefits of SASS and CSS variables by storing them in an object, where they can be globally updated. This object lives in `src/utils/styles/index.js`, and makes for incredibly easy theme changes.

Consider the following example:
```javascript
// styles/index.js:
export default const style_vars = {
  blue: 'rgb(29,31,177)',
  blue2: 'rgb(162,217,218)'
}
```

```javascript
// src/components/someComponent.js
import styled from 'styled-components';
import style_vars from '../utils/styles';

const StyledDiv = styled.div`
  color: ${style_vars.blue};
  background-color: ${style_vars.blu2};
`;

// Your compenent renders StyledDiv in its render method
```

You can then swap the colors to invert your color scheme, though you may want to do this with the theme feature built into styled-components.

---

```
npm i -g craftool
craft {{ AppName }} https://github.com/steph-query/craft-redux/archive/master.zip
```

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
