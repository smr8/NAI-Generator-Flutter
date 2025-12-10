import 'dart:math';

import '../../core/constants/defaults.dart';
import 'generation_size.dart';

class ParamConfig {
  List<GenerationSize> sizes;
  int nSamples;

  int steps;
  String sampler;
  String noiseSchedule;
  double scale;
  double cfgRescale;
  bool sm;
  bool smDyn;
  bool varietyPlus;

  bool randomSeed;
  int seed;

  bool dynamicThresholding;
  double controlNetStrength;
  double uncondScale;

  bool qualityToggle;
  int ucPreset;
  String negativePrompt;

  bool legacy;
  bool addOriginalImage;

  int modelIndex = 0;

  bool autoPosition;
  bool legacyUc;

  ParamConfig({
    this.modelIndex = 0,
    this.sizes = const [GenerationSize(height: 1216, width: 832)],
    this.scale = 6.5,
    this.sampler = 'k_euler_ancestral',
    this.steps = 28,
    this.randomSeed = true,
    this.seed = 0,
    this.nSamples = 1,
    this.ucPreset = 2,
    this.qualityToggle = false,
    this.sm = true,
    this.smDyn = true,
    this.dynamicThresholding = false,
    this.controlNetStrength = 1.0,
    this.legacy = false,
    this.addOriginalImage = false,
    this.uncondScale = 1.0,
    this.cfgRescale = 0.1,
    this.noiseSchedule = 'native',
    this.varietyPlus = false,
    this.negativePrompt = defaultUC,
    this.autoPosition = false,
    this.legacyUc = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'model_index': modelIndex,
      'sizes': sizes.map((elem) => elem.toJson()).toList(),
      'scale': scale,
      'sampler': sampler,
      'steps': steps,
      'n_samples': nSamples,
      'ucPreset': ucPreset,
      'qualityToggle': qualityToggle,
      'sm': sm,
      'sm_dyn': smDyn,
      'random_seed': randomSeed,
      'dynamic_thresholding': dynamicThresholding,
      'controlnet_strength': controlNetStrength,
      'legacy': legacy,
      'add_original_image': addOriginalImage,
      'uncond_scale': uncondScale,
      'cfg_rescale': cfgRescale,
      'noise_schedule': noiseSchedule,
      'negative_prompt': negativePrompt,
      'reference_image_multiple': [],
      'reference_information_extracted_multiple': [],
      'reference_strength_multiple': [],
      'variety_plus': varietyPlus,
      'auto_position': autoPosition,
      'legacy_uc': legacyUc,
    };
  }

  /// Different from toJson(), some fields in payload need to be calculated from other params.
  Map<String, dynamic> getPayload() {
    bool? preferBrownian;
    bool? deliberateEulerAncestralBug;
    if (sampler == 'k_euler_ancestral' && noiseSchedule != 'native') {
      preferBrownian = true;
      deliberateEulerAncestralBug = false;
    }
    double? skipCfgAboveSigma;
    final selectedSize = sizes[Random().nextInt(sizes.length)];
    final width = selectedSize.width;
    final height = selectedSize.height;
    if (varietyPlus) {
      final w = width / 8;
      final h = height / 8;
      final v = pow(4.0 * w * h / 63232, 0.5);
      skipCfgAboveSigma = 19.0 * v;
    }
    var payload = {
      "params_version": 3,
      "width": width,
      "height": height,
      "scale": scale,
      "sampler": sampler,
      "steps": steps,
      "n_samples": nSamples,
      "ucPreset": 2,
      "qualityToggle": false,
      'sm': sm,
      'sm_dyn': smDyn,
      "dynamic_thresholding": dynamicThresholding,
      "controlnet_strength": controlNetStrength,
      "legacy": legacy,
      "add_original_image": true,
      "cfg_rescale": cfgRescale,
      "noise_schedule": noiseSchedule,
      "skip_cfg_above_sigma": skipCfgAboveSigma,
      "use_coords": true,
      "seed": randomSeed ? Random().nextInt(1 << 32 - 1) : seed,
      "characterPrompts": [],
      "v4_prompt": {},
      "v4_negative_prompt": {},
      "negative_prompt": negativePrompt,
      "reference_image_multiple": [],
      "reference_information_extracted_multiple": [],
      "reference_strength_multiple": [],
      "deliberate_euler_ancestral_bug": deliberateEulerAncestralBug,
      "prefer_brownian": preferBrownian,
      "legacy_uc": legacyUc,
    };
    payload['legacy_v3_extend'] = false;
    payload.removeWhere((k, v) => v == null);
    // Always apply V4 logic for new API models
    payload.remove('sm');
    payload.remove('sm_dyn');
    if (noiseSchedule.contains('native')) {
      payload['noise_schedule'] = 'karras';
    }
    return payload;
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory ParamConfig.fromJson(Map<String, dynamic> json) {
    return ParamConfig(
      modelIndex: _parseInt(json['model_index'], 0),
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((elem) => GenerationSize.fromJson(elem))
              .toList() ??
          const [GenerationSize(height: 1216, width: 832)],
      scale: _parseDouble(json['scale'], 6.5),
      sampler: json['sampler'] ?? 'k_euler_ancestral',
      steps: _parseInt(json['steps'], 28),
      nSamples: _parseInt(json['n_samples'], 1),
      ucPreset: _parseInt(json['ucPreset'], 2),
      qualityToggle: json['qualityToggle'] ?? false,
      sm: json['sm'] ?? true,
      smDyn: json['sm_dyn'] ?? true,
      dynamicThresholding: json['dynamic_thresholding'] ?? false,
      varietyPlus: json['variety_plus'] ?? false,
      controlNetStrength: _parseDouble(json['controlnet_strength'], 1.0),
      legacy: json['legacy'] ?? false,
      addOriginalImage: json['add_original_image'] ?? false,
      uncondScale: _parseDouble(json['uncond_scale'], 1.0),
      cfgRescale: _parseDouble(json['cfg_rescale'], 0.1),
      noiseSchedule: json['noise_schedule'] ?? 'native',
      negativePrompt: json['negative_prompt'] ?? defaultUC,
      autoPosition: json['auto_position'] ?? false,
      legacyUc: json['legacy_uc'] ?? false,
    );
  }

  int loadJson(Map<String, dynamic> json) {
    int loadCount = 0;
    if (json.containsKey('width') && json.containsKey('height')) {
      final width = _parseInt(json['width'], 1024);
      final height = _parseInt(json['height'], 1024);
      sizes = [GenerationSize(width: width, height: height)];
      loadCount += 2;
    }
    if (json.containsKey('scale')) {
      scale = _parseDouble(json['scale'], 6.5);
      loadCount++;
    }
    if (json.containsKey('sampler')) {
      sampler = json['sampler'];
      loadCount++;
    }
    if (json.containsKey('steps')) {
      steps = _parseInt(json['steps'], 28);
      loadCount++;
    }
    if (json.containsKey('n_samples')) {
      nSamples = _parseInt(json['n_samples'], 1);
      loadCount++;
    }
    if (json.containsKey('ucPreset')) {
      ucPreset = _parseInt(json['ucPreset'], 2);
      loadCount++;
    }
    if (json.containsKey('qualityToggle')) {
      qualityToggle = json['qualityToggle'];
      loadCount++;
    }
    if (json.containsKey('sm')) {
      sm = json['sm'];
      loadCount++;
    }
    if (json.containsKey('sm_dyn')) {
      smDyn = json['sm_dyn'];
      loadCount++;
    }
    if (json.containsKey('dynamic_thresholding')) {
      dynamicThresholding = json['dynamic_thresholding'];
      loadCount++;
    }
    if (json.containsKey('controlnet_strength')) {
      controlNetStrength = _parseDouble(json['controlnet_strength'], 1.0);
      loadCount++;
    }
    if (json.containsKey('legacy')) {
      legacy = json['legacy'];
      loadCount++;
    }
    if (json.containsKey('add_original_image')) {
      addOriginalImage = json['add_original_image'];
      loadCount++;
    }
    if (json.containsKey('uncond_scale')) {
      uncondScale = _parseDouble(json['uncond_scale'], 1.0);
      loadCount++;
    }
    if (json.containsKey('cfg_rescale')) {
      cfgRescale = _parseDouble(json['cfg_rescale'], 0.1);
      loadCount++;
    }
    if (json.containsKey('noise_schedule')) {
      noiseSchedule = json['noise_schedule'];
      loadCount++;
    }
    if (json.containsKey('negative_prompt')) {
      negativePrompt = json['negative_prompt'];
      loadCount++;
    }
    if (json.containsKey('seed')) {
      seed = _parseInt(json['seed'], 0);
      randomSeed = false;
      loadCount++;
    }
    if (json.containsKey('use_coords')) {
      autoPosition = json['use_coords'];
      loadCount++;
    }
    if (json.containsKey('uc')) {
      negativePrompt = json['uc'];
      loadCount++;
    }
    return loadCount;
  }
}
