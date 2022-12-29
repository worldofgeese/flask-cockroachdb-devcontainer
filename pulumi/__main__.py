'''This is the main entrypoint for your Pulumi program.'''
import pulumi_gcp as gcp
import pulumi

config = pulumi.Config()
flask_app_container_image = config.require('flask_app_container_image')
location = config.require("location")
container_port = config.require("container_port")
project = config.require("project")


default = gcp.cloudrun.Service("default",
    location=location,
    project=project,
    template=gcp.cloudrun.ServiceTemplateArgs(
        spec=gcp.cloudrun.ServiceTemplateSpecArgs(
            containers=[gcp.cloudrun.ServiceTemplateSpecContainerArgs(
                commands=["flask", "run", "--host=0.0.0.0"],
                image=flask_app_container_image,
                ports=[
                    gcp.cloudrun.ServiceTemplateSpecContainerPortArgs(
                        container_port=container_port,
                    )
                ],
                envs=[
                    gcp.cloudrun.ServiceTemplateSpecContainerEnvArgs(
                        name="FLASK_APP",
                        value="project/__init__.py",
                    )
                ],
            )],
        ),
    ),
    traffics=[gcp.cloudrun.ServiceTrafficArgs(
        latest_revision=True,
        percent=100,
    )])

pulumi.export("url", default.statuses[0].url)
