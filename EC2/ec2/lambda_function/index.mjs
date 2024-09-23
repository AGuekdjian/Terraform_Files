import AWS from "aws-sdk";
const ec2 = new AWS.EC2();

const getInstanceIds = async () => {
  try {
    const params = {
      Filters: [
        {
          Name: "tag:scheduler",
          Values: ["true"],
        },
      ],
    };

    const result = await ec2.describeInstances(params).promise();
    const instanceIds = [];

    result.Reservations.forEach((reservation) => {
      reservation.Instances.forEach((instance) => {
        console.log("Instance: ", instance.InstanceId);
        const nameTag = instance.Tags.find((tag) => tag.Key === "Name");
        console.log(nameTag);
        if (nameTag && nameTag.Value.includes("scheduler")) {
          instanceIds.push(instance.InstanceId);
          console.log(instanceIds);
        }
      });
    });

    return instanceIds;
  } catch (error) {
    console.error(`Error al obtener las instancias: ${error.message}`, error);
    throw new Error(`No se pudieron obtener las instancias: ${error.message}`);
  }
};

export const handler = async (event) => {
  const action = event.action;
  const instanceIds = await getInstanceIds();

  console.log(`Acción solicitada: ${action} para instancias: ${instanceIds}`);

  try {
    if (action === "start") {
      await startInstances(instanceIds);
    } else if (action === "stop") {
      await stopInstances(instanceIds);
    } else {
      throw new Error(`Acción inválida: ${action}`);
    }

    return {
      statusCode: 200,
      body: JSON.stringify(
        `Acción ${action} ejecutada en las instancias: ${instanceIds}`
      ),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: error.message }),
    };
  }
};

// Funciones para iniciar y detener instancias
const startInstances = async (instanceIds) => {
  if (instanceIds.length > 0) {
    await ec2.startInstances({ InstanceIds: instanceIds }).promise();
    console.log(`Iniciando instancias: ${instanceIds}`);
  } else {
    console.log("No hay instancias para iniciar.");
  }
};

const stopInstances = async (instanceIds) => {
  if (instanceIds.length > 0) {
    await ec2.stopInstances({ InstanceIds: instanceIds }).promise();
    console.log(`Deteniendo instancias: ${instanceIds}`);
  } else {
    console.log("No hay instancias para detener.");
  }
};
