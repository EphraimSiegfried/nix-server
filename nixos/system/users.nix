{ pkgs, ... }:
{
  nix.settings.trusted-users = [
    "root"
    "siegi"
  ];

  users.users = {
    siegi = {
      isNormalUser = true;
      description = "Ephraim";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM56oJGPCghkpixf0EET44ehH5K2VyCzf+NLfPSCxnq1 siegi@thymian"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK/2Bk4xJbVzAWxZ9ApsC2io+Df6uAqiH6sa4I9HhwQO Termius"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdANrCkeXTrZha/w3pvg/vCZWmuRsy7cI6PmgVfWH8c siegi@blinkybill"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPZa8HXrUXJsTeaEf7/+MNEe6VhfcTR6U6wb1hr5AVwKwD5im7a41bXR7JvgB0PGVi9jotF0rNXk5jtcKAhUMSVc9fot47fFuD+dPUaafRwrasWCpSFVLxqIXmsYBoyBep/CNr28Cu2b6qpCx+APjt2gyELQzPh4Dt6C7qsNI4UfvpaLz+tmBJGcwbhtZTLp0MRquL3d2p7ss6/v6WFblhBORBsgU+Qltl5JTsSyT3Puqut+ilUxMdtUbJ7iug0fh/4k3292jlVUTChBI+JUvkHAQHuFwikWOz6MT/iA8Xee2J0UprFPOYqzGGLEggMWTpO2vc3Zww7HOfmDl9edE6CPMhlhGBV0ueH4Bbk5W8hrszZn089cNQKP4NGZVVFAoYpTGJ602NMBdq3pdJxesIDlIxxZujbRs23bvKICR1UFbrxox6kfUD3aBOJNTr03pDGYqahSIip/mgGOIzwi5EH91oQ+AXtXpwEjMNK2qw3bYOyzBXVAWgrWHNOSBsP7fiK1UM8Gd733rijwu6eRC9x1JrHYop/t7gLkLzAAYNoTjo/cnIyo8pp0w0mUhf61bLsE5tt8P8Gc9PQ9xFE6pU+qKmM5bNqgW5nCzS9+O25Zjp0CeTOUrOg7cB9hWPc7lEj2N7IF54WrxLsai4kZE+IZ2C9l8qkm4r8t27QsGi8w== pvonf@Shoreham"
      ];
    };

    zenoli = {
      isNormalUser = true;
      description = "zenoli";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHDzWzxwPdbgyyPqfalsGiotORwoXBVq3L1AuZ9yDFp4"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGxusYiPzAUe3ZwVJjt/n5ERJNOftq73X2J5cSWAQKpfMZuhcdoyTJsoVpc6DmHLvDK6a+gZPc5WHhF85HZEPKTAqXGPvpC/4XKiK+UyI8ldwR00ssSHjmvu8DDJ9nojuI9Q54Kk/XfOeqIwkVfKjQtPzCMfEGmDylGCmjrjr0LUNDUgCd4Gzr1mQZEGVFUKbyeZbGBIg+2U2GCVAQqw+eWSDaG6fdthiUtBfSZdiWKDpv8Bo02e/it9SK/G7j4UT39Y9Dfns3k1U+0juNJ7ngUQOy8Gl1Ad10TCzNbH1ErBTJgsnMy6iCNzwZlF73TtTs5ZPhG7Kx1CFiwA29XKSkz0Ja4sTwFHgnMBHbhKJDzg+8UiL7LFrtgKoQ2QY2URpbevKy/4gqpP8EmMeXUHGFvT4FYzplRQiIPSXeHjP1ylbp2OLF3oPzyvm/Hp3mGWu48VA6ENl8mz73g2ET3lx/3ulfI54hIy+0JmdICNVe5mSOgrlF8rLL7eJXXZe4j8HH+JwECBGJKicBL22B+TWe48FFaGL2c8X1oE61XuYEcqAoAGkTfmfqFBcx0DpNJqL+v5EU3sGfEQqD4tqSbbPDyPYzDcQnLn1e7NIr9VvmuvPZ8jOhRd8CrNlyuHUdTubKjNeGLOtQYpJztriY67aNnu7/9uOBy7BC+ZbdR7oiCQ== olibitter_@gmail.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIt8+GNnyf8Vw94xnky0AykkND5pgEoaZ7t+awBkuXfy olibitter@gmail.com"
      ];
    };

  };

}
