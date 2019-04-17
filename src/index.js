import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import styled, { ThemeProvider } from 'styled-components';
import { theme } from './utils/styles';
import { Switch, Route, BrowserRouter} from 'react-router-dom';

import store from './store';

import App from './containers/App';
import NotFound from './containers/NotFound';

ReactDOM.render(
  <BrowserRouter>
    <ThemeProvider theme={theme} >
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
    </ThemeProvider>
  </BrowserRouter>,
  document.getElementById('root')
);
