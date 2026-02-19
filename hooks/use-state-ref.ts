import { Dispatch, RefObject, SetStateAction, useRef, useState } from "react";

function useStateRef<T>(initialValue: T | (() => T)): [T, RefObject<T>, Dispatch<SetStateAction<T>>] {
  const [state, setState] = useState<T>(initialValue);
  const ref = useRef<T>(state);

  const setStateRef: Dispatch<SetStateAction<T>> = (value) => {
    setState(value);
    if (typeof value === "function") {
      // @ts-ignore
      ref.current = value(ref.current);
    } else {
      ref.current = value;
    }
  };

  return [state, ref, setStateRef];
}

export default useStateRef;