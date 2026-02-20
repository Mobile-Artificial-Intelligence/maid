import * as Application from "expo-application";
import * as Device from "expo-device";

function getMetadata(): Record<string, any> {
  return {
    appVersion: Application.nativeApplicationVersion || undefined,
    appBuild: Application.nativeBuildVersion || undefined,
    device: Device.modelName || undefined,
    osBuildId: Device.osBuildId || undefined,
    osVersion: Device.osVersion || undefined,
    cpu: Device.supportedCpuArchitectures || undefined,
    ram: Device.totalMemory || undefined,
    createTime: new Date().toISOString(),
  };
}

export default getMetadata;