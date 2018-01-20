import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import { Switch, Route, BrowserRouter} from 'react-router-dom';

import store from './store';

import App from './containers/App';
import NotFound from './containers/NotFound';

import './index.css';

ReactDOM.render(
  <BrowserRouter>
    <div className="App-header">
      <Provider store={store}>
        <Switch>
          <Route
            exactly
            pattern='/'
            component={App} />
          <Route component={NotFound} />
        </Switch>
      </Provider>
    </div>
  </BrowserRouter>,
  document.getElementById('root')
);
