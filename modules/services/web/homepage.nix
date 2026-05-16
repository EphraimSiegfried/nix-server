{
  flake.modules.nixos.homepage =
    { config, lib, ... }:
    let
      port = 8082;

      # Group services by category
      categories = lib.groupBy (svc: svc.category) (lib.attrValues config.webServices);

      mkServiceEntry = svc: {
        ${svc.name} = {
          href =
            if svc.subdomain == "@" then
              config.baseURL
            else
              let
                parts = lib.splitString "://" config.baseURL;
                scheme = builtins.head parts;
                rest = builtins.elemAt parts 1;
              in
              "${scheme}://${svc.subdomain}.${rest}";
          icon = svc.icon;
          description = svc.description;
        };
      };

      mkCategory = name: svcs: {
        ${name} = map mkServiceEntry svcs;
      };
    in
    {
      webServices.homepage = {
        name = "Homepage";
        subdomain = "@";
        inherit port;
        description = "Dashboard";
      };

      services.homepage-dashboard = {
        enable = true;
        listenPort = port;
        allowedHosts = "*";
        settings = {
          title = "Zenolium";
          description = "Welcome to Zenolium";
          background = {
            image = "https://preview.redd.it/space-wallpapers-4k-3840-2160-v0-xlbdzh75m88f1.jpg?width=1080&crop=smart&auto=webp&s=325d1f2a3c59d23ecbbdf6ad10000299b11b94b9";
            blur = "md";
          };
        };
        services = lib.mapAttrsToList mkCategory (lib.filterAttrs (name: _: name != "Services") categories);
        widgets = [
          {
            resources = {
              cpu = true;
              disk = [
                "/"
                "/media"
              ];
              memory = true;
            };
          }
        ];
      };
    };
}
