{ self, inputs, ... }: {
  den.aspects.ci-darwin = {
    darwin = { ... }: {
      users.users.runner.home = "/Users/runner";
    };
  };
}
