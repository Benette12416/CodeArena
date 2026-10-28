<?php
header('Cache-Control: no-store, private');
require_once __DIR__ . '/../app/bootstrap.php';
require_once __DIR__ . '/../app/layout.php';
require_once __DIR__ . '/../app/learning_paths.php';
$user = require_role(['student']);
$id = max(0, (int)($_GET['id'] ?? 0));
$pathId = max(0, (int)($_GET['path_id'] ?? 0));

$stmt = $pdo->prepare("SELECT e.* FROM exercises e WHERE e.id=? AND e.is_published=1
    AND NOT EXISTS (SELECT 1 FROM class_assignments ca WHERE ca.exercise_id=e.id AND ca.is_active=1)");
$stmt->execute([$id]);
$exercise = $stmt->fetch();
if (!$exercise) {
    flash('This challenge is not available in Practice Mode. Open classroom assignments from My Classes.', 'error');
    redirect('index.php#practice');
}

// Published learning-path exercises must be opened with their path context so step locks cannot be bypassed by removing the query string.
if ($pathId < 1) {
    $linkedPathId = ca_find_published_path_for_exercise($pdo, $id);
    if ($linkedPathId !== null) {
        flash('Open this challenge from its learning path. Finish each step in order to unlock the next.', 'info');
        redirect('student-learning-paths.php?path_id=' . $linkedPathId);
    }
}

$pathContext = null;
$pathItem = null;
$isPathStep = $pathId > 0;
if ($isPathStep) {
    $gate = ca_assert_learning_path_step_unlocked($pdo, (int)$user['id'], $pathId, $id);
    if (!$gate['ok']) {
        flash($gate['reason'], 'error');
        redirect('student-learning-paths.php?path_id=' . $pathId);
    }
    $pathContext = $gate['context'];
    $pathItem = $gate['item'];
}

$isHtmlSeedExercise = str_starts_with((string)($exercise['slug'] ?? ''), 'ca-htmlcss-path-');
$isHtmlPreviewProject = $isHtmlSeedExercise && $isPathStep;
if ($isHtmlSeedExercise && !$isHtmlPreviewProject) {
    flash('Open this HTML/CSS project from its learning path so your progress can be saved.', 'info');
    redirect('student-learning-paths.php');
}
$defaultLanguage = 'python';
$pathLanguageSpecific = false;
if (preg_match('/^ca-(python|cpp|c|java|php|ruby)-path-/', (string)($exercise['slug'] ?? ''), $langMatch)) { $defaultLanguage = $langMatch[1]; $pathLanguageSpecific = true; }
$pathCompleted = $isPathStep && !empty($pathItem['completed']);
$lessonCompleted = $pathCompleted;
if ($isHtmlPreviewProject && function_exists('codearena_table_exists') && codearena_table_exists($pdo, 'learning_path_completions')) {
    $doneCheck = $pdo->prepare('SELECT 1 FROM learning_path_completions WHERE user_id=? AND path_id=? AND exercise_id=? LIMIT 1');
    $doneCheck->execute([(int)$user['id'], $pathId, $id]);
    $lessonCompleted = $pathCompleted || (bool)$doneCheck->fetchColumn();
}
$samplesStmt = $pdo->prepare('SELECT stdin,expected_output FROM test_cases WHERE exercise_id=? AND is_sample=1 ORDER BY sort_order,id LIMIT 10');
$samplesStmt->execute([$id]);
$samples = $samplesStmt->fetchAll();
$totalTestsStmt = $pdo->prepare('SELECT COUNT(*) FROM test_cases WHERE exercise_id=?');
$totalTestsStmt->execute([$id]);
$totalTestCases = (int)$totalTestsStmt->fetchColumn();
$baseUrl = rtrim($config['base_url'], '/');
$pathUrl = $baseUrl . '/student-learning-paths.php' . ($pathId > 0 ? '?path_id=' . $pathId : '');
$backUrl = $isPathStep ? 'student-learning-paths.php?path_id=' . $pathId : 'index.php#practice';
$load_codemirror = true;
page_header('Practice · ' . $exercise['title']);
?>
<section class="v14-practice-head">
  <div>
    <a class="back" href="<?= e($baseUrl) ?>/<?= e($backUrl) ?>">← <?= $isPathStep ? 'Back to learning path' : 'Back to Practice Arena' ?></a>
    <p class="eyebrow"><?= $isPathStep ? 'LEARNING PATH · STEP ' . sprintf('%02d', (int)$pathItem['position']) . ' OF ' . sprintf('%02d', (int)$pathItem['total_steps']) : 'PRACTICE MODE · NO OFFICIAL GRADE' ?></p>
    <h1><?= e($exercise['title']) ?></h1>
    <p class="muted"><?= $isPathStep ? 'Pass every public and hidden test to complete this step and unlock the next challenge.' : 'Explore the solution at your own pace. Practice runs never create official submissions, attempts, or classroom grades.' ?></p>
    <div class="v14-practice-meta"><span class="difficulty <?= strtolower(e($exercise['difficulty'])) ?>"><?= e($exercise['difficulty']) ?></span><span class="pill"><?= e($exercise['topic'] ?? 'Fundamentals') ?></span><span class="pill">No timer</span><?php if ($isPathStep): ?><span class="pill"><?= (int)$exercise['points'] ?> points</span><?php endif; ?></div>
  </div>
  <div class="v14-practice-safety"><span class="safety-icon">⌘</span><strong><?= $isPathStep ? 'Sequential learning' : 'Safe practice space' ?></strong><p><?= $isPathStep ? 'The next step stays locked until this solution passes all test cases. Hidden test details stay private.' : 'Only public sample cases are checked here. Hidden grading tests are not run or revealed in Practice Arena.' ?></p></div>
</section>
<?php if ($isPathStep && $pathCompleted): ?><div class="v22-path-complete-banner"><span class="v22-path-complete-icon">✓</span><div><strong>This learning path step is complete.</strong><p>You can review the code, and the next step is unlocked in your path.</p></div><a class="button small" href="<?= e($pathUrl) ?>">Continue path →</a></div><?php endif; ?>
<div class="v14-practice-layout">
  <section class="panel v14-practice-problem">
    <div class="section-title"><div><h2>Problem</h2><p class="muted">Read the task and use the input/output examples.</p></div></div>
    <div class="v14-problem-description"><?= nl2br(e($exercise['description'])) ?></div>
    <?php if ($isHtmlPreviewProject): ?>
      <div class="alert info"><strong>Web project mode</strong><p>Use Preview HTML to inspect your page in the sandboxed preview. Visual design is not auto-graded; compare your work with the project checklist, then mark this step complete.</p></div>
    <?php elseif ($samples): ?>
      <div class="v14-public-samples"><h3>Public samples</h3><?php foreach ($samples as $index => $sample): ?><article class="v14-sample-pair"><strong>Sample <?= $index + 1 ?></strong><div class="v14-sample-grid"><div><small>Input</small><pre><?= e($sample['stdin']) ?></pre></div><div><small>Expected output</small><pre><?= e($sample['expected_output']) ?></pre></div></div></article><?php endforeach; ?></div>
    <?php else: ?><div class="alert info">No public sample cases have been added yet. Ask the teacher to add at least one public example.</div><?php endif; ?>
  </section>
  <section class="panel v14-practice-editor">
    <div class="v14-practice-editor-head"><div><p class="eyebrow">EDITOR</p><h2><?= $isHtmlPreviewProject ? 'Build your web project' : 'Try your solution' ?></h2></div><label>Language<select id="practiceLanguage"><?php if ($isHtmlPreviewProject): ?><option value="html">HTML/CSS preview</option><?php elseif ($isPathStep && $pathLanguageSpecific): ?><option value="<?= e($defaultLanguage) ?>" selected><?= e(strtoupper($defaultLanguage === 'cpp' ? 'C++' : $defaultLanguage)) ?> · required for this path</option><?php else: ?><option value="python" <?= $defaultLanguage === 'python' ? 'selected' : '' ?>>Python</option><option value="cpp" <?= $defaultLanguage === 'cpp' ? 'selected' : '' ?>>C++</option><option value="c" <?= $defaultLanguage === 'c' ? 'selected' : '' ?>>C</option><option value="java" <?= $defaultLanguage === 'java' ? 'selected' : '' ?>>Java</option><option value="php" <?= $defaultLanguage === 'php' ? 'selected' : '' ?>>PHP</option><option value="ruby" <?= $defaultLanguage === 'ruby' ? 'selected' : '' ?>>Ruby</option><?php endif; ?></select></label></div>
    <textarea id="practiceSource" class="code v14-practice-code" spellcheck="false" aria-label="Practice source code"><?= e($exercise['starter_code'] ?: "# Write your solution here\n") ?></textarea>
    <div class="v14-practice-input" id="practiceInputWrap" <?= $isHtmlPreviewProject ? 'hidden' : '' ?>><label for="practiceStdin">Custom standard input</label><textarea id="practiceStdin" class="code" rows="4" placeholder="Enter input for your program"></textarea></div>
    <div class="v21-html-preview-wrap" id="htmlPreviewWrap" <?= $isHtmlPreviewProject ? '' : 'hidden' ?>><div class="subsection-heading"><h3>Live HTML/CSS preview</h3><span class="muted">Sandboxed iframe · scripts blocked</span></div><iframe id="htmlPreviewFrame" sandbox="" title="HTML and CSS project preview"></iframe></div>
    <div class="v14-practice-actions">
      <button class="button secondary" id="practiceRunCustom" type="button"><?= $isHtmlPreviewProject ? '▷ Preview HTML' : '▶ Run custom input' ?></button>
      <button class="button" id="practiceRunSamples" type="button" <?= ($isHtmlPreviewProject || !$samples) ? 'hidden disabled' : '' ?>>✓ Check public samples</button>
      <?php if ($isPathStep && !$isHtmlPreviewProject): ?><button class="button v22-submit-path-step" id="practiceSubmitPath" type="button" <?= ($pathCompleted || $totalTestCases < 1) ? 'disabled' : '' ?>><?= $pathCompleted ? '✓ Step completed' : '✓ Check solution & unlock next' ?></button><?php endif; ?>
    </div>
    <?php if ($isHtmlPreviewProject): ?>
      <form class="v21-complete-form" method="post" action="<?= e($baseUrl) ?>/practice-complete.php"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="exercise_id" value="<?= (int)$id ?>"><input type="hidden" name="path_id" value="<?= (int)$pathId ?>"><button class="button <?= $lessonCompleted ? 'secondary' : '' ?>" type="submit" <?= $lessonCompleted ? 'disabled' : '' ?>><?= $lessonCompleted ? '✓ Project completed' : 'Mark project complete' ?></button><p class="field-hint">Preview-only projects must be marked complete manually. The step is still locked until all earlier steps are complete.</p></form>
    <?php endif; ?>
    <p class="field-hint"><?= $isPathStep ? 'The next step unlocks only when every public and hidden test passes. This does not change official classroom grades.' : 'The editor autosaves this practice draft in your browser. Nothing here changes official classroom grades.' ?></p>
    <section class="v14-practice-result" aria-live="polite"><div class="v14-practice-result-header"><h3 id="practiceResultTitle">Console / preview</h3><span id="practiceResultBadge" class="pill">Ready</span></div><pre id="practiceOutput"><?= $isPathStep ? 'Run your code, check public samples, or submit your path solution.' : 'Choose ' . ($isHtmlPreviewProject ? 'Preview HTML' : 'Run custom input or Check public samples') . '.' ?></pre><div id="practiceTestResults" class="v14-practice-tests"></div><a id="continuePathLink" class="button small v22-continue-path" href="<?= e($pathUrl) ?>" hidden>Return to learning path →</a></section>
  </section>
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.js"></script><script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/python/python.min.js"></script><script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/clike/clike.min.js"></script><script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/php/php.min.js"></script><script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/ruby/ruby.min.js"></script><script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/xml/xml.min.js"></script><script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/css/css.min.js"></script><script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/htmlmixed/htmlmixed.min.js"></script>
<script>
(() => {
 'use strict';
 const textarea=document.getElementById('practiceSource');
 const language=document.getElementById('practiceLanguage');
 const output=document.getElementById('practiceOutput');
 const badge=document.getElementById('practiceResultBadge');
 const resultTitle=document.getElementById('practiceResultTitle');
 const testsWrap=document.getElementById('practiceTestResults');
 const continueLink=document.getElementById('continuePathLink');
 const url=<?= json_encode($baseUrl . '/practice-run.php') ?>;
 const csrf=<?= json_encode(csrf_token()) ?>;
 const exerciseId=<?= (int)$id ?>;
 const pathId=<?= (int)$pathId ?>;
 const pathMode=<?= $isPathStep ? 'true' : 'false' ?>;
 const pathCompletedInitially=<?= $pathCompleted ? 'true' : 'false' ?>;
 const storageKey='codearena:practice:'+exerciseId+':'+<?= json_encode((string)$user['id']) ?>;
 const modes={python:'python',cpp:'text/x-c++src',c:'text/x-csrc',java:'text/x-java',php:'application/x-httpd-php',ruby:'ruby',html:'htmlmixed'};
 const htmlMode=<?= $isHtmlPreviewProject ? 'true' : 'false' ?>;
 const htmlPreview=document.getElementById('htmlPreviewFrame');
 const htmlWrap=document.getElementById('htmlPreviewWrap');
 const customBtn=document.getElementById('practiceRunCustom');
 const sampleBtn=document.getElementById('practiceRunSamples');
 const pathBtn=document.getElementById('practiceSubmitPath');
 let editor=null;
 try { if(window.CodeMirror){editor=CodeMirror.fromTextArea(textarea,{lineNumbers:true,indentUnit:4,tabSize:4,mode:modes[language.value],matchBrackets:true,autoCloseBrackets:true,viewportMargin:Infinity});editor.setSize('100%','390px');} } catch(_e){}
 function getCode(){return editor?editor.getValue():textarea.value;}
 function setCode(v){if(editor)editor.setValue(v);else textarea.value=v;}
 function updateHtmlPreview(){if(htmlMode&&htmlPreview){htmlPreview.srcdoc=getCode();htmlWrap.hidden=false;}}
 function restore(){try{const saved=JSON.parse(localStorage.getItem(storageKey)||'null');if(saved&&typeof saved.code==='string')setCode(saved.code);if(saved&&saved.language&&modes[saved.language]&&Array.from(language.options).some(o=>o.value===saved.language))language.value=saved.language;}catch(_e){}if(editor)editor.setOption('mode',modes[language.value]);}
 function save(){try{localStorage.setItem(storageKey,JSON.stringify({code:getCode(),language:language.value,savedAt:new Date().toISOString()}));}catch(_e){}if(htmlMode)updateHtmlPreview();}
 function el(tag,cls,text){const n=document.createElement(tag);if(cls)n.className=cls;if(text!==undefined)n.textContent=text;return n;}
 function showTest(test, mode){
   const hidden=Boolean(test.hidden);
   const card=el('article','v14-practice-test '+(test.passed?'passed':'failed'));
   const head=el('div','v14-practice-test-head');
   head.append(el('strong','',hidden?`Hidden test ${test.number}`:(mode==='samples'?`Sample ${test.number}`:`Test ${test.number}`)));
   head.append(el('span','pill',test.passed?'Passed':(hidden?'Not passed':test.status)));
   card.append(head);
   if(hidden){card.append(el('p','field-hint','Hidden test details are protected. This shows only the pass/fail result.'));}
   else {
     const blocks=el('div','v14-practice-test-output');
     for(const pair of [['Input',test.input],['Expected',test.expected_output],['Actual',test.actual_output]]){const block=el('div','');block.append(el('small','',pair[0]));block.append(el('pre','',pair[1]||'(no output)'));blocks.append(block);}
     card.append(blocks);if(test.error_output)card.append(el('pre','v14-practice-error',test.error_output));
   }
   testsWrap.append(card);
 }
 async function run(mode){
   save();
   if(htmlMode){updateHtmlPreview();resultTitle.textContent='HTML/CSS preview';badge.textContent='Preview updated';badge.className='pill grade-status-perfect';output.textContent='Your HTML/CSS has been loaded into the sandboxed preview. Check the result against the project checklist.';testsWrap.replaceChildren();return;}
   if(mode==='path'&&(!pathMode||pathCompletedInitially))return;
   const btn=mode==='custom'?customBtn:(mode==='samples'?sampleBtn:pathBtn);
   const buttons=[customBtn,sampleBtn,pathBtn].filter(Boolean);
   const oldLabels=buttons.map(b=>b.textContent);
   buttons.forEach(b=>{b.disabled=true;});
   btn.dataset.old=btn.textContent;btn.textContent=mode==='path'?'Checking all tests…':'Running…';
   badge.textContent='Running';badge.className='pill';testsWrap.replaceChildren();continueLink.hidden=true;
   output.textContent=mode==='path'?'Running public and hidden test cases securely…':'Contacting Judge0…';
   const data=new FormData();data.set('_csrf',csrf);data.set('exercise_id',String(exerciseId));data.set('path_id',String(pathId));data.set('language',language.value);data.set('source_code',getCode());data.set('mode',mode);data.set('stdin',document.getElementById('practiceStdin').value);
   try{
     const response=await fetch(url,{method:'POST',body:data,credentials:'same-origin',headers:{'X-Requested-With':'fetch'}});
     const result=await response.json();if(!response.ok||!result.ok)throw new Error(result.error||'Practice run failed.');
     if(mode==='custom'){
       resultTitle.textContent='Program output';badge.textContent=result.status;badge.className='pill';
       output.textContent=[result.stdout,result.compile_output,result.stderr].filter(Boolean).join('\n')||'(no output)';
       if(result.status!=='Accepted')badge.className='pill status-failed';
     } else if(mode==='samples'){
       resultTitle.textContent='Public sample results';badge.textContent=`${result.passed_samples}/${result.total_samples} passed`;badge.className='pill '+(result.all_samples_passed?'grade-status-perfect':'grade-status-partial');output.textContent=result.message;
       for(const test of result.tests||[])showTest(test,mode);
     } else {
       resultTitle.textContent='Learning path verification';badge.textContent=`${result.passed_tests}/${result.total_tests} passed`;badge.className='pill '+(result.all_tests_passed?'grade-status-perfect':'grade-status-partial');output.textContent=result.message;
       for(const test of result.tests||[])showTest(test,mode);
       if(result.completed){badge.textContent='Step completed';badge.className='pill grade-status-perfect';continueLink.hidden=false;pathBtn.disabled=true;pathBtn.textContent='✓ Step completed';}
     }
   }catch(error){output.textContent=error.message||'Could not run your code.';badge.textContent='Error';badge.className='pill status-failed';}
   finally{
     buttons.forEach((b,i)=>{if(b===pathBtn&&b.dataset.completed==='1')return;b.disabled=false;});
     if(sampleBtn && <?= $samples ? 'true' : 'false' ?>)sampleBtn.disabled=false;
     if(sampleBtn && <?= $samples ? 'false' : 'true' ?>)sampleBtn.disabled=true;
     if(pathBtn && (pathCompletedInitially || pathBtn.dataset.completed==='1' || badge.textContent==='Step completed')){pathBtn.disabled=true;pathBtn.dataset.completed='1';}
     else if(pathBtn)pathBtn.disabled=<?= $totalTestCases > 0 ? 'false' : 'true' ?>;
     customBtn.textContent='▶ Run custom input';if(sampleBtn)sampleBtn.textContent='✓ Check public samples';if(pathBtn&&pathBtn.dataset.completed!=='1')pathBtn.textContent='✓ Check solution & unlock next';
   }
 }
 language.addEventListener('change',()=>{if(editor)editor.setOption('mode',modes[language.value]);save();});
 if(editor)editor.on('change',save);else textarea.addEventListener('input',save);
 customBtn.addEventListener('click',()=>run('custom'));if(sampleBtn)sampleBtn.addEventListener('click',()=>run('samples'));if(pathBtn)pathBtn.addEventListener('click',()=>run('path'));
 restore();if(htmlMode)updateHtmlPreview();
})();
</script>
<?php page_footer(); ?>
