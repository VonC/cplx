# How to resume or repeat a step

<img src="../assets/logo-cplx-bridge-transparent.png" alt="" height="90" align="right">

Goal: re-run part of the setup pipeline (one step, a branch of steps, or
everything from a point on) without redoing what already succeeded.

The pipeline state lives in `src\setups\steps.md`: each step is a heading
carrying an anchor and, once finished, a ` (done: ✅)` marker. A marked
step is skipped on the next run. Two verbs act on the markers:

- **repeat**: clear one step and its children (siblings stay done),
- **reset**: clear one step and *everything after it*.

## 📋 Steps

1. See where the pipeline stands:

   ```cmd
   git diff src\setups\steps.md
   ```

   (a textconv configured by `senv.bat` hides the markers from diffs, so
   look at the file itself to see the ✅ marks).

2. Repeat or reset from the command line. The name is fuzzy-matched, so a
   fragment is enough; this is exactly what the `scpe`/`scps` aliases do:

   ```cmd
   s copy_the_sources     &:: repeat this step (and its substeps)
   s r_copy_the_sources   &:: reset: this step and all following ones
   scps                   &:: shorthand for s "copy.*source"
   ```

3. Or pin it in the environment, useful for a step you want re-run every
   time (`senv.local.bat` ships with
   `CPLX_REPEAT_STEP=validate_the_ssh_connection`):

   ```bat
   set "CPLX_REPEAT_STEP=download_sources"
   set "CPLX_RESET_STEP=copy_the_environment"
   ```

4. For the package pipeline, the checkpoint is not in `steps.md` but in
   `src\setups\pkgs\<tool>\last` (the last processed package):

   ```cmd
   sp reset                    &:: forget the checkpoint, restart the list
   s package reset zlib-devel  &:: resume exactly at this line
   sp p_zlib-devel             &:: or process one single package
   ```

5. After editing step titles by hand, regenerate the anchors:

   ```cmd
   sfa src/setups/steps.md
   ```

## ✅ Check

Running `s` again re-executes the intended step (watch the `[setup.sh]`
task lines) and leaves the previously done siblings untouched.

Related: [steps.md format](../reference/steps-file-format.md),
[Checkpoints and resume](../explanation/checkpoints-and-resume.md).
