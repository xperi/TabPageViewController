//
//  CollectionFlowLayout.swift
//  Pods
//
//  Created by xperi on 2016. 10. 5..
//
//
import UIKit

enum ScrollDirection {
    case None
    case Right
    case Left

    static func direction(origin: CGFloat, moved: CGFloat) -> ScrollDirection {
        if origin > 0 {
            if origin > moved {
                return .Left
            } else if origin < moved {
                return .Right
            }
        }
        return .None
    }
}

public class CollectionFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        if let cv = self.collectionView {
            let contentWidth = cv.contentSize.width
            let contentOffset = cv.contentOffset
            let scrollDirection = ScrollDirection.direction(contentOffset.x, moved: proposedContentOffset.x)
            let cvBounds = cv.bounds
            let fullWidth = cvBounds.size.width
            let halfWidth = fullWidth * 0.5

            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth

            if let attributesForVisibleCells = self.layoutAttributesForElementsInRect(cvBounds) {

                var candidateAttributes: UICollectionViewLayoutAttributes?
                var candidateAttributesList = [UICollectionViewLayoutAttributes]()
                for attributes in attributesForVisibleCells {

                    if attributes.representedElementCategory != UICollectionElementCategory.Cell {
                        continue
                    }

                    let attributesCenterX  = attributes.center.x

                    if scrollDirection == .Left {
                        if attributesCenterX < contentOffset.x + halfWidth {
                            candidateAttributesList.append(attributes)
                        }
                    } else if scrollDirection == .Right {
                        if attributesCenterX > contentOffset.x + halfWidth {
                            candidateAttributesList.append(attributes)
                        }
                    } else {
                        candidateAttributesList.append(attributes)
                    }
                }

                for attributes in candidateAttributesList {
                    if let candAttrs = candidateAttributes {
                        let attributesCenterX  = attributes.center.x
                        let a = attributesCenterX - proposedContentOffsetCenterX
                        let b = candAttrs.center.x - proposedContentOffsetCenterX
                        if fabsf(Float(a)) < fabsf(Float(b)) {
                            candidateAttributes = attributes
                        }
                    } else {
                        candidateAttributes = attributes
                    }
                }

                if let candidateAttributes = candidateAttributes {
                    let candidateAttributesCenterX = candidateAttributes.center.x
                    let proposedContentOffsetX = proposedContentOffset.x

                    if candidateAttributesCenterX <= halfWidth {
                        return CGPoint(x : 0, y : proposedContentOffset.y)
                    } else if contentWidth <= proposedContentOffsetX + fullWidth {
                        return CGPoint(x : contentWidth, y : proposedContentOffset.y)
                    }

                    return CGPoint(x : candidateAttributes.center.x - halfWidth, y : proposedContentOffset.y)
                }

            }

        }

        // Fallback
        return super.targetContentOffsetForProposedContentOffset(proposedContentOffset)
    }
}
