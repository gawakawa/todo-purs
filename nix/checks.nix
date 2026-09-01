_: {
  perSystem =
    { projects, ... }:
    {
      checks = {
        frontend-tests = projects.frontend.ps.test.check { };
        backend-tests = projects.backend.ps.test.check { };
      };
    };
}
