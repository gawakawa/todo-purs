_: {
  perSystem =
    { frontend, backend, ... }:
    {
      checks = {
        frontend-tests = frontend.ps.test.check { };
        backend-tests = backend.ps.test.check { };
      };
    };
}
