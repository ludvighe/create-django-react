import { Route, Switch } from "react-router-dom";
import { HomePage } from "./components/pages/home-page";

export const Routes = () => (
  <Switch>
    <Route path="/" component={HomePage} />
  </Switch>
);
