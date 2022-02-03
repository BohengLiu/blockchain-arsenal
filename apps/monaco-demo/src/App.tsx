import React from "react";
import Editor, { OnMount, useMonaco, BeforeMount } from "@monaco-editor/react";
import { editor, languages } from "monaco-editor/esm/vs/editor/editor.api";

function App() {
  const monacoRef = useMonaco();
  const editorRef = React.useRef<editor.IStandaloneCodeEditor | null>(null);

  const handleRun = () => {
    if (editorRef.current) {
      const code = editorRef.current.getValue();
      const modal = editorRef.current.getModel();
      console.log("code", code);
      console.log("modal", modal);
      const fn = new Function("global", `with(global) {${code}}`);
      fn({
        readline: () => {
          console.log("readline");
          return "readline";
        },
      });
    }
  };

  const onBeforeMount: BeforeMount = (_monaco) => {
    _monaco.languages.typescript.typescriptDefaults.setCompilerOptions({
      target: _monaco.languages.typescript.ScriptTarget.ES2016,
      allowNonTsExtensions: true,
      moduleResolution:
        _monaco.languages.typescript.ModuleResolutionKind.NodeJs,
      module: _monaco.languages.typescript.ModuleKind.CommonJS,
      noEmit: true,
      lib: ["es2020"],
    });

    _monaco.languages.typescript.typescriptDefaults.setDiagnosticsOptions({
      noSemanticValidation: false,
      noSyntaxValidation: false,
    });

    const global = `
      declare global {
        /**
         * Read a line from stdin
         */
        function readline(): string;
        /**
         * Print a string to stdout
         * @deprecated Use console.log instead
         */
        function print(word: string): void;
      }
      // It needs to be a module
      export {}
    `;

    _monaco.languages.typescript.typescriptDefaults.addExtraLib(
      global,
      "global.d.ts"
    );
  };

  const onEditorDidMount: OnMount = (_editor, _monaco) => {
    editorRef.current = _editor;
    (window as any)._cr = {
      editor: _editor,
      mon: _monaco,
    };
    // const model = editor.getModel();

    console.log("_editor", _editor);
    console.log("_monaco", _monaco);

    _editor.onKeyDown((evt) => {
      console.log("onKeyDown evt", evt);
      if (evt.shiftKey) {
        editorRef.current &&
          editorRef.current.trigger(
            "auto completion",
            "editor.action.triggerSuggest",
            {}
          );
      }
    });

    _editor.onDidChangeCursorPosition((evt) => {
      console.log("onDidChangeCursorPosition evt", evt);
    });

    _editor.onMouseDown((evt) => {
      console.log("onMouseDown evt", evt);
      console.log("position", evt.target.position);
    });

    _editor.onDidChangeModelContent((evt) => {
      console.log("onDidChangeModelContent evt", evt);
    });
  };

  console.log("monaco", monacoRef);

  const defaultValue = `// some comment
  readline()`;
  return (
    <>
      <header
        style={{
          height: "10vh",
          background: "#111",
          display: "flex",
          alignItems: "center",
        }}
      >
        <button onClick={handleRun}>on Run</button>
      </header>
      <Editor
        height="90vh"
        defaultLanguage="typescript"
        theme="vs-dark"
        defaultValue={defaultValue}
        options={{
          selectOnLineNumbers: true,
          // renderSideBySide: false,
        }}
        beforeMount={onBeforeMount}
        onMount={onEditorDidMount}
      />
    </>
  );
}

export default App;
