from mmdet.apis import init_detector, inference_detector, show_result_pyplot
import glob

# https://github.com/open-mmlab/mmdetection/blob/master/docs/model_zoo.md
config_file = 'configs/faster_rcnn/faster_rcnn_r101_fpn_2x_coco.py'
checkpoint_file = 'checkpoints/faster_rcnn_r101_fpn_2x_coco_20200504.pth'

# config_file = 'configs/mask_rcnn/mask_rcnn_r101_fpn_2x_coco.py'
# checkpoint_file = 'checkpoints/mask_rcnn_r101_fpn_2x_coco_20200505.pth'

# config_file = 'configs/retinanet/retinanet_r101_fpn_2x_coco.py'
# checkpoint_file = 'checkpoints/retinanet_r101_fpn_2x_coco_20200131.pth'

# config_file = 'configs/yolo/yolov3_d53_mstrain-416_273e_coco.py'
# checkpoint_file = 'checkpoints/yolov3_d53_mstrain-416_273e_coco.pth'

# config_file = 'xianjin/mask_rcnn_r101_fpn_2x_coco.py'
# checkpoint_file = 'xianjin/epoch_24.pth'

# 初始化模型
# device='cuda:0'
model = init_detector(config_file, checkpoint_file, device='cpu')

# 测试一系列图片
# imgs = ['ImageData/demo.jpg',  'ImageData/demo.png', 'ImageData/test01.png',
#         'ImageData/test04.png', 'ImageData/test05.png', 'ImageData/test06.png']

imgs = glob.glob('ImageData/*.jpg')


for i, result in enumerate(inference_detector(model, imgs)):
    show_result_pyplot(model, imgs[i], result)

